//
//  SheetCoordinator.swift
//
//  Copyright (c) Andres F. Lozano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import SUICoordinatorCore

/// Manages the modal presentation stack for a `Router`.
///
/// `SheetCoordinator` maintains an ordered list of `SheetItem` entries and drives
/// SwiftUI sheet and full-screen-cover presentation through the `@Observable` property
/// `items`. Each entry can represent a plain route view or a child coordinator.
///
/// Dismissal is synchronised with the SwiftUI view layer via `onFinish`: when a
/// non-coordinator sheet disappears, `RouterView` sends the dismissed index string on
/// `onFinish`, which unblocks the `removeSheet(at:animated:)` continuation that is
/// waiting for that confirmation.
@available(iOS 17.0, *)
@MainActor
@Observable
final class SheetCoordinator<T> {

    public typealias Item = SheetItem<T>

    /// The current presentation stack observed by SwiftUI.
    ///
    /// Entries are set to `nil` when a sheet begins dismissing so SwiftUI can animate
    /// the removal. Nil entries are compacted out after the animation completes.
    var items: [Item?]

    @ObservationIgnored
    private let itemManager = ItemManager<Item?>()
    /// The presentation style of the most recently presented or dismissed sheet.
    @ObservationIgnored
    public private(set) var lastPresentationStyle: TransitionPresentationStyle?
    /// Whether the topmost sheet item represents a child coordinator.
    @ObservationIgnored
    public private(set) var isCoordinator: Bool = false
    /// Whether the last presentation or dismissal was animated.
    @ObservationIgnored
    public private(set) var animated: Bool?
    @ObservationIgnored
    private var backUpItems: [Int: String]
    /// Called when a sheet is removed from the stack (e.g. swiped away by the user).
    /// The argument is the sheet item's `id`.
    @ObservationIgnored
    var onRemoveItem: ((String) async -> Void)?
    /// Broadcast channel used to synchronise view-layer dismissal with `removeSheet(at:animated:)`.
    ///
    /// `RouterView` sends the string representation of the dismissed index when a
    /// non-coordinator sheet's `onDisappear` fires. `removeSheet` awaits this signal
    /// before returning so callers can rely on the animation having completed.
    @ObservationIgnored
    var onFinish: AsyncBroadcast<String> = .init()

    init(
        items: [Item?] = [],
        lastPresentationStyle: TransitionPresentationStyle? = nil,
        animated: Bool? = nil,
        backUpItems: [Int : String] = [:],
        onRemoveItem: ((String) async -> Void)? = nil
    ) {
        self.items = items
        self.lastPresentationStyle = lastPresentationStyle
        self.animated = animated
        self.backUpItems = backUpItems
        self.onRemoveItem = onRemoveItem
    }

    private var totalItems: Int {
        get async { await itemManager.totalItems }
    }

    /// `true` when the stack contains no non-nil items.
    var areEmptyItems: Bool {
        get async { await itemManager.areItemsEmpty() }
    }

    /// Appends a sheet to the presentation stack.
    ///
    /// - Parameter sheet: The `SheetItem` to present.
    public func presentSheet(_ sheet: Item) async -> Void {
        animated = sheet.animated
        lastPresentationStyle = sheet.presentationStyle
        isCoordinator = sheet.isCoordinator
        
        await itemManager.addItem(sheet)
        await backUpItems[totalItems] = sheet.id
        await updateItems()
    }

    /// Removes the topmost non-nil sheet from the stack.
    ///
    /// - Parameter animated: Whether the dismissal should be animated.
    func removeLastSheet(animated: Bool) async -> Void {
        guard !(await areEmptyItems),
              let totalItems = await itemManager.getAllItems().lastIndex(where: { $0 != nil })
        else { return await updateItems() }
        await removeSheet(at: totalItems, animated: animated)
    }

    /// Removes the sheet at the given index and waits for the view layer to confirm dismissal.
    ///
    /// For non-coordinator sheets the function suspends on `onFinish` until `RouterView`
    /// sends the matching index string from its `onDisappear` handler. This ensures callers
    /// return only after the SwiftUI dismissal animation has completed.
    ///
    /// - Parameters:
    ///   - index: The position in `items` to remove.
    ///   - animated: Whether the dismissal should be animated.
    func removeSheet(at index: Int, animated: Bool) async -> Void {
        self.animated = animated
        await updateLastPresentationStyle()
        
        if lastPresentationStyle?.isCustom == true {
            await itemManager.getItem(at: index)?.willDismiss.send()
        }
        
        await itemManager.makeItemsNil(at: index)
        await updateItems()
        
        if !isCoordinator {
            let stream = await onFinish.stream()
            for await value in stream {
                if let inComingIndex = Int(value), inComingIndex == index {
                    break
                }
            }
        }
    }

    /// Called by the view layer when a sheet is removed outside of programmatic control
    /// (e.g. the user swipes the sheet away).
    ///
    /// Fires `onRemoveItem` for coordinator items above the removed index, compacts nil
    /// entries, and broadcasts the index on `onFinish` to unblock any `removeSheet`
    /// continuation that is waiting for that index.
    ///
    /// - Parameter index: The string representation of the zero-based stack index to remove.
    func remove(at index: String) async {
        guard let index = Int(index), (await itemManager.isValid(index: index)) else {
            return await updateItems()
        }
        
        let nextIndex = index + 1
        
        await removeCustomSheets(at: nextIndex)

        if let id = backUpItems[index] {
            await onRemoveItem?(id)
            backUpItems.removeValue(forKey: index)
        }

        guard (await itemManager.removeItem(at: index)) != nil else {
            await updateLastPresentationStyle()
            return await updateItems()
        }

        await handleRemove(index: nextIndex)
        await updateLastPresentationStyle()
        await removeAllNilItems()
        await onFinish.send("\(index)")
    }
    
    /// Dismisses all sheets in the stack and resets coordinator state.
    ///
    /// Sheets are removed from top to bottom in groups separated by presentation-style
    /// boundaries (sheet vs full-screen-cover). Only the final dismissal in each group
    /// is animated when `animated` is `true`; intermediate dismissals are instant.
    ///
    /// - Parameter animated: Whether the last dismissal in each boundary group should
    ///   be animated. Defaults to `true`.
    func clean(animated: Bool = true) async -> Void {
        let items = await buildItemsToRemove()

        for index in items {
            let animated = items.last == index ? animated : false
            await removeSheet(at: index, animated: animated)
        }
        
        await itemManager.removeAll()
        await updateItems()
        
        lastPresentationStyle = nil
        backUpItems.removeAll()
    }

    /// Returns the index immediately following `index`.
    func getNextIndex(_ index: Int) -> Int {
        index + 1
    }

    /// Returns `true` if `index` is the last valid position in `items`, or if `items` is empty.
    func isLastIndex(_ index: Int) -> Bool {
        let totalItems = items.count - 1
        return items.isEmpty || index == totalItems
    }

    /// Removes all `nil` placeholder entries from the stack and refreshes `items`.
    func removeAllNilItems() async {
        await itemManager.removeAllNilItems()
        await updateItems()
    }

    /// Syncs the observable `items` array from the backing `itemManager`.
    func updateItems() async {
        items = await itemManager.getAllItems()
    }
    
    /// Removes any custom-transition sheets at or above `index`.
    ///
    /// Called before removing a sheet so that orphaned custom-transition overlays
    /// (which don't dismiss automatically with their parent) are cleaned up first.
    ///
    /// - Parameter index: The stack position from which to start scanning upward.
    private func removeCustomSheets(at index: Int) async {
        let items = await itemManager.getAllItems()
        
        guard items.indices.contains(index) else { return }
        
        let customItems = Array(items.suffix(from: index))
            .filter { $0?.presentationStyle.isCustom == true }
        
        for item in customItems {
            if let index = await itemManager.getAllItems().firstIndex(where: { $0?.id == item?.id }) {
                await remove(at: "\(index)")
            }
        }
    }

    /// Refreshes `lastPresentationStyle` and `isCoordinator` from the current stack.
    ///
    /// Called before and after sheet removal so these properties always reflect the
    /// topmost remaining item rather than the item that was just dismissed.
    private func updateLastPresentationStyle() async {
        let items = await itemManager.getAllItems()
        
        let presentationStyle = items.last(where: {
            $0?.presentationStyle != nil
        })??.presentationStyle
        
        if presentationStyle != lastPresentationStyle {
            lastPresentationStyle = presentationStyle
        }
        
        if let isCoordinator = items.last(where: { $0?.isCoordinator != nil })??.isCoordinator {
            self.isCoordinator = isCoordinator
        }
    }

    /// Fires `onRemoveItem` for every coordinator-backed sheet at or above `index`.
    ///
    /// After a sheet is removed, any child coordinators that were stacked above it are
    /// no longer reachable. This method walks the range `index..<items.count` and
    /// notifies the parent coordinator to finish those children via `onRemoveItem`.
    ///
    /// - Parameter index: The first stack position to scan for coordinator items.
    private func handleRemove(index: Int) async {
        guard (await itemManager.isValid(index: index)) else { return }
        
        let items = await itemManager.getAllItems()
        let range = index..<items.count
        
        for i in range {
            if let item = items[i],
               item.isCoordinator == true,
               let element = getBackupItemIndex(by: item.id)
            {
                backUpItems.removeValue(forKey: element.key)
                await onRemoveItem?(element.value)
            }
        }
    }

    /// Returns the `backUpItems` entry whose value matches `value`, or `nil` if not found.
    ///
    /// - Parameter value: The sheet item `id` to look up.
    private func getBackupItemIndex(by value: String) -> Dictionary<Int, String>.Element? {
        backUpItems.first(where: { $0.value == value })
    }
    
    /// Computes the ordered list of stack indices that `clean()` must dismiss.
    ///
    /// Only the "root" index of each contiguous presentation-style group needs an
    /// explicit `removeSheet` call — SwiftUI dismisses the sheets above it automatically.
    /// A new group starts whenever the presentation style switches between
    /// `.fullScreenCover` and anything else. Indices are returned in reverse order
    /// (top of stack first) so `clean()` dismisses from the top down.
    ///
    /// - Returns: Stack indices to dismiss, ordered from top to bottom.
    private func buildItemsToRemove() async -> [Int] {
        let items = await itemManager.getAllItems()
        let paired = zip(items, [nil] + items)

        return zip(items.indices, paired)
            .compactMap { index, pair in
                
                let (current, previous) = pair
                let isCurrentPresentationStyle = current?.presentationStyle == .fullScreenCover
                let isPreviousPresentationStyle = previous?.presentationStyle == .fullScreenCover
                
                return (
                    previous == nil ||
                    isCurrentPresentationStyle && !isPreviousPresentationStyle ||
                    !isCurrentPresentationStyle && isPreviousPresentationStyle
                ) ? index : nil
            }
            .reversed()
    }
}
