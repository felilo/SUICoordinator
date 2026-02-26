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

/// A class representing a coordinator for managing and presenting sheets in a coordinator-based architecture.
///
/// `SheetCoordinator` handles the presentation and removal of modal sheets in a structured way,
/// providing a stack-based approach to sheet management. It supports multiple concurrent sheets,
/// different presentation styles, and proper lifecycle management.
///
/// ## Key Features
/// - **Stack-based Management**: Maintains a stack of sheet items for complex modal flows
/// - **Multiple Presentation Styles**: Supports `.sheet`, `.fullScreenCover`, and custom presentation styles
/// - **Animation Control**: Configurable animation for sheet presentations and dismissals
/// - **Automatic Cleanup**: Handles proper cleanup when sheets are dismissed
/// - **Coordinator Integration**: Special handling for coordinator-based sheet content
/// - **Thread Safety**: Uses actors internally for safe concurrent access
///
/// ## Usage Example
/// ```swift
/// let sheetCoordinator = SheetCoordinator<AnyView>()
///
/// // Present a simple view
/// let viewItem = SheetItem(
///     id: "example-sheet",
///     animated: true,
///     presentationStyle: .sheet
/// ) { AnyView(Text("Hello World")) }
///
/// await sheetCoordinator.presentSheet(viewItem)
/// ```
final public class SheetCoordinator<T>: ObservableObject {
    
    // ---------------------------------------------------------
    // MARK: typealias
    // ---------------------------------------------------------
    
    /// A type alias representing the sheet item containing a view conforming to the generic type `T`.
    ///
    /// This type alias provides a cleaner way to reference sheet items throughout the coordinator.
    public typealias Item = SheetItem<T>
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The stack of sheet items managed by the coordinator.
    ///
    /// Each item in the stack is an optional `SheetItem`. This allows handling cases where
    /// certain items might need to be removed or temporarily set to `nil` during dismissal.
    /// The array maintains the order of presentation, with the first item being the bottom-most sheet.
    @Published var items: [Item?]
    
    /// Thread-safe item manager for coordinating access to sheet items.
    ///
    /// This actor-based manager ensures safe concurrent access to the sheet items,
    /// preventing race conditions when multiple operations occur simultaneously.
    private let itemManager = ItemManager<Item?>()

    /// The presentation style of the last presented sheet.
    ///
    /// This property is updated whenever a new sheet is presented. It reflects the most recent
    /// `TransitionPresentationStyle` used in the presentation and helps coordinate dismissal behavior.
    public private(set) var lastPresentationStyle: TransitionPresentationStyle?
    
    /// A boolean value indicating whether the last sheet presentation was animated.
    ///
    /// This property is updated whenever a new sheet is presented, capturing whether
    /// the transition to the presented sheet was animated or not.
    public private(set) var animated: Bool?
    
    /// A backup dictionary storing item-related metadata for cleanup purposes.
    ///
    /// The key is an `Int` identifier representing the item's position, and the value is a `String`
    /// representing the sheet item's identifier. This is used for proper cleanup when items are removed.
    private var backUpItems: [Int: String]
    
    /// A closure that is invoked when a sheet item is removed from the stack.
    ///
    /// The closure receives a `String` value representing the identifier of the removed item.
    /// This can be used to handle clean-up operations for coordinators or perform additional
    /// tasks upon item removal.
    ///
    /// - Parameter identifier: The identifier of the removed sheet item.
    var onRemoveItem: ((String) async -> Void)?
    
    // ---------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------
    
    /// Initializes a new instance of `SheetCoordinator`.
    ///
    /// Creates an empty sheet coordinator ready to manage modal presentations.
    /// The coordinator starts with no active sheets and can immediately begin accepting
    /// sheet presentation requests.
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
    
    // ---------------------------------------------------------
    // MARK: Computed vars
    // ---------------------------------------------------------
    
    /// The total number of sheet items currently in the stack.
    ///
    /// This computed property provides thread-safe access to the current count of managed sheet items.
    /// It's useful for validation and debugging purposes.
    @MainActor
    private var totalItems: Int {
        get async { await itemManager.totalItems }
    }
    
    /// A boolean value indicating whether the items stack is empty.
    ///
    /// This computed property provides thread-safe access to check if any sheets are currently managed.
    var areEmptyItems: Bool {
        get async { await itemManager.areItemsEmpty() }
    }
    
    // ---------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------
    
    /// Presents a sheet with the specified item.
    ///
    /// This method adds the sheet item to the managed stack and handles the presentation
    /// according to the item's configuration. It updates internal state to track the
    /// presentation style and animation preferences.
    ///
    /// - Parameters:
    ///   - sheet: The sheet item to present, containing the view/coordinator, presentation style,
    ///            and animation preferences.
    ///
    /// - Note: This method is marked `@MainActor` to ensure UI updates occur on the main thread.
    @MainActor public func presentSheet(_ sheet: Item) async -> Void {
        animated = sheet.animated
        lastPresentationStyle = sheet.presentationStyle
        
        await itemManager.addItem(sheet)
        await backUpItems[totalItems] = sheet.id
        await updateItems()
    }
    
    /// Removes the last presented sheet from the stack.
    ///
    /// This method dismisses the most recently presented sheet and handles proper cleanup.
    /// For custom presentation styles, it sends a dismissal signal; for standard styles,
    /// it removes the item from the stack.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the removal.
    @MainActor func removeLastSheet(animated: Bool) async -> Void {
        guard !(await areEmptyItems) else { return await updateItems() }
        
        self.animated = animated
        let totalItems = await totalItems
        
        await updateLastPresentationStyle()
        
        if lastPresentationStyle?.isCustom == true {
            await itemManager.getItem(at: totalItems)?.willDismiss.send()
        } else {
            await itemManager.makeItemsNil(at: totalItems)
        }
        
        await updateItems()
    }
    
    /// Removes sheets at the specified indices.
    ///
    /// This method allows for bulk removal of sheets at specific positions in the stack.
    /// It's useful for complex dismissal scenarios where multiple sheets need to be removed.
    ///
    /// - Parameters:
    ///   - index: An array of indices indicating which sheets to remove.
    ///   - animated: A boolean value indicating whether to animate the removal.
    func removeSheet(at index: [Int], animated: Bool) async -> Void {
        self.animated = animated
        
        await updateLastPresentationStyle()
        await itemManager.makeItemsNil(at: index)
        await updateItems()
    }
    
    /// Removes the item at the specified string index.
    ///
    /// This method handles the removal of a specific sheet item by its string identifier.
    /// It performs validation, cleanup of backup items, and proper coordinator cleanup.
    ///
    /// - Parameters:
    ///   - index: The string representation of the index of the item to remove.
    @MainActor func remove(at index: String) async {
        guard let index = Int(index),
              (await itemManager.isValid(index: index))
        else { return await updateItems() }
        
        if let id = backUpItems[index] {
            await onRemoveItem?(id)
            backUpItems.removeValue(forKey: index)
        }
        
        guard (await itemManager.removeItem(at: index)) != nil else {
            await updateLastPresentationStyle()
            return await updateItems()
        }
        
        await handleRemove(index: index - 1)
        await updateLastPresentationStyle()
        await removeAllNilItems()
    }
    
    /// Cleans up the sheet coordinator, optionally animating the cleanup process.
    ///
    /// This method provides intelligent cleanup that handles different presentation styles appropriately.
    /// For full screen covers, it prioritizes dismissing them first; for regular sheets, it dismisses
    /// from the bottom of the stack.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the cleanup process. Defaults to `true`.
    @MainActor func clean(animated: Bool = true) async -> Void {
        let items = await itemManager.getAllItems()
        var indexes = [0]
        
        if let firstFSIndex = items.firstIndex(where: { $0?.presentationStyle == .fullScreenCover }) {
            indexes = [firstFSIndex]
            if let firstSheetIndex = items.firstIndex(where: { $0 != nil && $0?.presentationStyle != .fullScreenCover }) {
                indexes.append(firstSheetIndex)
            }
        }
        
        await removeSheet(at: indexes, animated: animated)
        try? await Task.sleep(for: .seconds(animated ? 0.1 : 0))
    }
    
    /// Returns the next index based on the given index.
    ///
    /// This utility method provides a simple way to calculate the next position in the stack.
    ///
    /// - Parameter index: The current index.
    /// - Returns: The next index incremented by 1.
    func getNextIndex(_ index: Int) -> Int {
        index + 1
    }

    /// Checks whether the given index is the last index in the items array.
    ///
    /// This method helps determine if a given index represents the top-most sheet in the stack.
    ///
    /// - Parameter index: The current index to check.
    /// - Returns: A boolean value indicating whether the given index is the last index
    ///           or if the items array is empty.
    @MainActor func isLastIndex(_ index: Int) -> Bool {
        let totalItems = items.count - 1
        
        return items.isEmpty || index == totalItems
    }
    
    // ---------------------------------------------------------
    // MARK: Private helper funcs
    // ---------------------------------------------------------
    
    /// Removes all `nil` items from the items array.
    ///
    /// This cleanup method ensures the items array doesn't accumulate nil values,
    /// maintaining a clean state for the sheet stack.
    func removeAllNilItems() async {
        await itemManager.removeAllNilItems()
        await updateItems()
    }
    
    /// Updates the `items` published property with the current state from the `itemManager`.
    ///
    /// This method synchronizes the published items array with the internal item manager state,
    /// triggering UI updates when the sheet stack changes.
    ///
    /// - Important: This function must be called on the main actor to ensure thread safety.
    @MainActor
    func updateItems() async {
        items = await itemManager.getAllItems()
    }
    
    /// Updates the `lastPresentationStyle` property based on the last non-nil item in the `itemManager`.
    ///
    /// This method ensures the presentation style tracking remains accurate by finding the
    /// most recent valid presentation style in the stack.
    ///
    /// - Important: This function must be called on the main actor to ensure thread safety.
    private func updateLastPresentationStyle() async {
        let presentationStyle = await itemManager.getAllItems().last(where: {
            $0?.presentationStyle != nil
        })??.presentationStyle
        
        guard presentationStyle != lastPresentationStyle else { return }
        
        lastPresentationStyle = presentationStyle
    }
    
    /// Handles the removal of coordinator items from the backup and invokes `onRemoveItem` for each.
    ///
    /// This method is called after an item is removed to clean up associated coordinator data.
    /// It identifies coordinator-based items that need cleanup and ensures proper resource deallocation.
    ///
    /// - Parameter index: The index from which to start checking for coordinator items to remove.
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
    
    /// Retrieves a backup item entry by its identifier value.
    ///
    /// This utility method searches the backup items dictionary to find an entry
    /// with a matching identifier value.
    ///
    /// - Parameter value: The identifier value to search for.
    /// - Returns: The dictionary element (key-value pair) if found, or `nil` if not found.
    private func getBackupItemIndex(by value: String) -> Dictionary<Int, String>.Element? {
        backUpItems.first(where: { $0.value == value})
    }
}
