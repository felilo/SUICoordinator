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

/// A class representing a coordinator for managing and presenting sheets.
///
/// Sheet coordinators handle the presentation and removal of sheets in a coordinator-based architecture.
final public class SheetCoordinator<T>: ObservableObject {
    
    // ---------------------------------------------------------
    // MARK: typealias
    // ---------------------------------------------------------
    
    /// A type alias representing the sheet item containing a view conforming to the `View` protocol.
    public typealias Item = SheetItem<T>
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The stack of sheet items managed by the coordinator.
    @Published var items: [Item?]
    
    /// The presentation style of the last presented sheet.
    public private(set) var lastPresentationStyle: TransitionPresentationStyle?
    
    /// The presentation style of the last presented sheet.
    public private(set) var animated: Bool?
    
    private var backUpItems: [Int: String] = [:]
    
    var onRemoveItem: ((String) -> Void)?
    
    // ---------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------
    
    /// Initializes a new instance of `SheetCoordinator`.
    public init() {
        items = []
    }
    
    // ---------------------------------------------------------
    // MARK: Computed vars
    // ---------------------------------------------------------
    
    /// The total number of sheet items in the stack.
    private var totalItems: Int {
        guard !items.isEmpty else {
            return 0
        }
        
        return items.count - 1
    }
    
    // ---------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------
    
    /// Presents a sheet with the specified item.
    ///
    /// - Parameters:
    ///   - sheet: The item representing the sheet to present.
    ///   - animated: A boolean value indicating whether to animate the sheet presentation.
    @MainActor public func presentSheet(_ sheet: Item) -> Void {
        if sheet.animated {
            items.append(nil)
        }
        animated = sheet.animated
        lastPresentationStyle = sheet.presentationStyle
        items.append(sheet)
        backUpItems[totalItems - 1] = sheet.id
    }
    
    /// Removes the last presented sheet.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the removal.
    @MainActor func removeLastSheet(animated: Bool) async -> Void {
        guard !items.isEmpty else { return }
        self.animated = animated
        lastPresentationStyle = items.last(where: { $0?.presentationStyle != nil })??.presentationStyle
        await makeNilItem(at: totalItems)
    }
    
    /// Removes the item at the specified index.
    ///
    /// - Parameters:
    ///   - index: The index of the item to remove.
    @MainActor func remove(at index: Int) {
        guard isValidIndex(index) else { return }
        
        if let id = backUpItems[index] {
            onRemoveItem?(id)
            backUpItems.removeValue(forKey: index)
        }
        
        items.remove(at: index)
    }
    
    /// Cleans up the sheet coordinator, optionally animating the cleanup process.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the cleanup process.
    @MainActor func clean(animated: Bool = true) async -> Void {
        await makeNilItem(at: 0)
        lastPresentationStyle = nil
        items.removeAll()
        backUpItems.removeAll()
    }
    
    // ---------------------------------------------------------
    // MARK: Private helper funcs
    // ---------------------------------------------------------
    
    /// Removes all `nil` items from the items array.
    @MainActor func removeAllNilItems() {
        items.removeAll(where: { $0 == nil || $0?.view == nil })
    }
    
    /// Makes item `nil` at the specified index.
    ///
    /// - Parameters:
    ///   - index: The index at which to remove `nil` items.
    @MainActor private func makeNilItem(at index: Int) async {
        guard isValidIndex(index) else { return }
        items[index] = nil
    }
    
    func getNextIndex(_ index: Int) -> Int {
        index + 1
    }
    
    func isLastIndex(_ index: Int) -> Bool {
        items.isEmpty || index == totalItems
    }
    
    func isValidIndex(_ index: Int) -> Bool {
        !items.isEmpty && items.indices.contains(index)
    }
}
