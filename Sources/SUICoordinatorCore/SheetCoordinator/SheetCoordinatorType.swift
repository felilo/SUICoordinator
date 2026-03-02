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

/// A protocol that defines the interface for a sheet coordinator.
///
/// `SheetCoordinatorType` provides the contract for managing modal sheet presentations
/// in a coordinator-based architecture. Platform-specific implementations add the
/// appropriate observation mechanism (`ObservableObject` or `@Observable`).
public protocol SheetCoordinatorType {
    
    associatedtype T
    typealias Item = SheetItem<T>
    
    /// The stack of sheet items managed by the coordinator.
    var items: [Item?] { get set }
    
    /// The presentation style of the last presented sheet.
    var lastPresentationStyle: TransitionPresentationStyle? { get }
    
    /// The total number of sheet items currently in the stack.
    var totalItems: Int { get }
    
    /// Presents a sheet with the specified item.
    @MainActor func presentSheet(_ sheet: Item) async -> Void
    
    /// Removes the last presented sheet from the stack.
    @MainActor func removeLastSheet(animated: Bool) async -> Void
    
    /// Removes the item at the specified string index.
    @MainActor func remove(at index: String) async
    
    /// Cleans up the sheet coordinator.
    @MainActor func clean(animated: Bool) async -> Void
}
