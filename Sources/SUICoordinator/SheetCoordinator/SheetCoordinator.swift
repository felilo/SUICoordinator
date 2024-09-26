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
import SwiftUI


/// A class representing a coordinator for managing and presenting sheets.
///
/// Sheet coordinators handle the presentation and removal of sheets in a coordinator-based architecture.
@available(iOS 16.0, *)
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
    
    /// A flag indicating whether the coordinator is in the process of cleaning up.
    private var isCleaning: Bool = false
    
    /// The presentation style of the last presented sheet.
    public private (set) var lastPresentationStyle: TransitionPresentationStyle?
    
    /// The presentation style of the last presented sheet.
    public private (set) var animated: Bool?
    
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
    var totalItems: Int {
        items.count - 1
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
    }
    
    /// Removes the last presented sheet.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the removal.
    func removeLastSheet(animated: Bool) -> Void {
        guard !items.isEmpty, !isCleaning else { return }
        self.animated = animated
        lastPresentationStyle = items.last(where: { $0?.presentationStyle != nil })??.presentationStyle
        makeNilItem(at: totalItems)
    }
    
    /// Removes the item at the specified index.
    ///
    /// - Parameters:
    ///   - index: The index of the item to remove.
    @MainActor func remove(at index: Int) {
        guard totalItems >= index, !isCleaning else { return }
        items.remove(at: index)
    }
    
    /// Cleans up the sheet coordinator, optionally animating the cleanup process.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the cleanup process.
    func clean(animated: Bool = true) -> Void {
        guard !items.isEmpty, !isCleaning else { return }
        
        isCleaning = true
        makeNilItem(at: 0)
        resetValues()
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
    private func makeNilItem(at index: Int) {
        items[index] = nil
    }
    
    /// Resets values associated with the sheet coordinator.
    private func resetValues() {
        items = []
        lastPresentationStyle = nil
        isCleaning = false
    }
}
