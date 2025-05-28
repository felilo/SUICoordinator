//
//  SheetCoordinatorType.swift
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

import SwiftUI

/// A protocol representing a type for managing and presenting sheets in a coordinator-based architecture.
///
/// `SheetCoordinatorType` defines the interface for handling the presentation and removal of modal sheets
/// in a structured, coordinator-based navigation system. It provides a consistent way to manage
/// multiple sheets, handle their lifecycle, and coordinate their presentation styles.
///
/// Sheet coordinators implementing this protocol can manage a stack of sheets, allowing for
/// complex modal presentation flows while maintaining proper cleanup and memory management.
///
/// ## Key Features
/// - Stack-based sheet management for multiple concurrent sheets
/// - Configurable presentation styles per sheet
/// - Automatic cleanup and memory management
/// - Animation control for sheet transitions
/// - Support for both views and coordinators as sheet content
public protocol SheetCoordinatorType: ObservableObject {
    
    // ---------------------------------------------------------
    // MARK: Type Aliases
    // ---------------------------------------------------------
    
    /// A type alias representing a sheet item containing any SwiftUI view.
    ///
    /// This type alias simplifies working with sheet items that can contain any type of SwiftUI view,
    /// providing type safety while maintaining flexibility for different view types.
    typealias Item = SheetItem<(any View)>
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// An array of optional sheet items currently managed by the sheet coordinator.
    ///
    /// This array maintains the stack of presented sheets, where each element represents
    /// a sheet that is currently presented or pending presentation. Optional values allow
    /// for proper cleanup when sheets are dismissed.
    ///
    /// The array is ordered from the first presented sheet to the most recently presented sheet.
    var items: [Item?] { get set }
    
    /// The last presentation style used for presenting sheets.
    ///
    /// This property tracks the most recent presentation style to ensure consistency
    /// in dismissal behavior and to help coordinate multiple sheet presentations.
    ///
    /// - Note: This value is updated automatically when sheets are presented.
    var lastPresentationStyle: TransitionPresentationStyle? { get set }
    
    /// The total number of currently active sheet items.
    ///
    /// This computed property provides a quick way to determine how many sheets
    /// are currently managed by the coordinator, which is useful for validation
    /// and debugging purposes.
    var totalItems: Int { get }
    
    // ---------------------------------------------------------
    // MARK: Functions
    // ---------------------------------------------------------
    
    /// Presents a sheet with the specified sheet item.
    ///
    /// This method adds the sheet item to the managed collection and presents it
    /// according to its configured presentation style and animation preferences.
    ///
    /// - Parameters:
    ///   - sheet: The sheet item representing the sheet to present. This includes
    ///            the view/coordinator content, presentation style, and animation preferences.
    ///
    /// - Important: This method is async to handle the presentation timing properly
    ///              and ensure smooth animations.
    func presentSheet(_ sheet: Item) async -> Void
    
    /// Removes the last presented sheet from the stack.
    ///
    /// This method dismisses the most recently presented sheet and removes it from
    /// the managed collection. It respects the animation preference and handles
    /// proper cleanup of the dismissed sheet.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the dismissal.
    ///               When `true`, the sheet will be dismissed with animation.
    ///
    /// - Note: If no sheets are currently presented, this method has no effect.
    func removeLastSheet(animated: Bool) async -> Void
    
    /// Removes the sheet item at the specified index.
    ///
    /// This method removes a specific sheet from the managed collection without
    /// necessarily dismissing it from the UI. This is useful for cleanup operations
    /// when sheets are dismissed through other means (like user interaction).
    ///
    /// - Parameters:
    ///   - index: The index of the sheet item to remove from the collection.
    ///
    /// - Important: Ensure the index is valid before calling this method to avoid crashes.
    func remove(at index: Int) -> Void
    
    /// Cleans up the sheet coordinator by removing all sheets and performing cleanup operations.
    ///
    /// This method dismisses all currently presented sheets and performs necessary
    /// cleanup operations to free resources and reset the coordinator state.
    /// It should be called when the sheet coordinator is no longer needed.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the cleanup process.
    ///               When `true`, all sheets will be dismissed with animation.
    ///
    /// - Important: After calling this method, the sheet coordinator should be considered
    ///              reset and ready for new sheet presentations.
    func clean(animated: Bool) async -> Void
}
