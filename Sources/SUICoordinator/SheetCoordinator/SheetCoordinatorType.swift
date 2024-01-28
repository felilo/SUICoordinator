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

/// A protocol representing a type for managing and presenting sheets.
///
/// Sheet coordinator types define the interface for handling the presentation and removal of sheets
/// in a coordinator-based architecture.
public protocol SheetCoordinatorType: ObservableObject {
    
    // ---------------------------------------------------------
    // MARK: Type Aliases
    // ---------------------------------------------------------
    
    /// A type alias representing a sheet item containing any view.
    typealias Item = SheetItem<(any View)>
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// An array of optional sheet items associated with the sheet coordinator type.
    var items: [Item?] { get set }
    
    /// The last presentation style used for presenting sheets.
    var lastPresentationStyle: TransitionPresentationStyle? { get set }
    
    /// The total number of items in the sheet coordinator type.
    var totalItems: Int { get }
    
    // ---------------------------------------------------------
    // MARK: Functions
    // ---------------------------------------------------------
    
    /// Presents a sheet with the specified sheet item.
    ///
    /// - Parameters:
    ///   - sheet: The sheet item representing the sheet to present.
    func presentSheet(_ sheet: Item) async -> Void
    
    /// Removes the last presented sheet.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the removal.
    func removeLastSheet(animated: Bool) async -> Void
    
    /// Removes the sheet item at the specified index.
    ///
    /// - Parameters:
    ///   - index: The index of the sheet item to remove.
    func remove(at index: Int) -> Void
    
    /// Cleans up the sheet coordinator, optionally animating the cleanup process.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the cleanup process.
    func clean(animated: Bool) async -> Void
}
