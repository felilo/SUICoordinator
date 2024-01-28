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
    @MainActor public func presentSheet(_ sheet: Item, animated: Bool = true) async -> Void {
        lastPresentationStyle = sheet.presentationStyle
        
        let runAction = { [weak self] () -> Void in
            self?.items.append(sheet)
            self?.removeAllNilItems()
        }
        
        if animated {
            items.append(nil)
            await makeDelay(
                animated: animated,
                customTime: 60 / 1000
            )
            return runAction()
        }
        
        runAction()
    }
    
    /// Removes the last presented sheet.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the removal.
    @MainActor func removeLastSheet(animated: Bool = true) async -> Void {
        guard !items.isEmpty, !isCleaning else { return }
        
        removeNilItems(at: totalItems)
        await makeDelay(animated: animated)
        removeAllNilItems()
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
    @MainActor func clean(animated: Bool = true) async -> Void {
        guard !items.isEmpty, !isCleaning else { return }
        
        isCleaning = true
        removeNilItems(at: 0)
        await makeDelay(animated: animated)
        resetValues()
    }
    
    // ---------------------------------------------------------
    // MARK: Private helper funcs
    // ---------------------------------------------------------
    
    /// Removes all `nil` items from the items array.
    private func removeAllNilItems() {
        items.removeAll(where: { $0 == nil || $0?.view == nil })
    }
    
    /// Removes `nil` items at the specified index.
    ///
    /// - Parameters:
    ///   - index: The index at which to remove `nil` items.
    private func removeNilItems(at index: Int) {
        items[index] = nil
    }
    
    /// Resets values associated with the sheet coordinator.
    private func resetValues() {
        items = []
        lastPresentationStyle = nil
        isCleaning = false
    }
    
    /// Delays execution optionally with a custom time.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the delay.
    ///   - customTime: An optional custom time for the delay.
    private func makeDelay(animated: Bool, customTime: Double? = nil) async -> Void {
        var milliSeconds: Double
        if let customTime {
            milliSeconds = customTime
        } else {
            milliSeconds = (animated ? 600 : 300) / 1000
        }
        try? await Task.sleep(for: .seconds(milliSeconds))
    }
}
