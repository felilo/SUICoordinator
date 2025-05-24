//
//  SheetItemType.swift
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
import Combine

/// A protocol defining the requirements for an item that can be presented as a sheet.
///
/// `SheetItemType` ensures that any conforming type can provide necessary information
/// for sheet presentation, such as an identifier, animation preference, presentation style,
/// and dismissal lifecycle management.
///
/// This protocol is essential for the sheet coordination system, allowing different types
/// of sheet items to be managed uniformly while maintaining their specific characteristics.
///
/// ## Key Features
/// - **Unique Identification**: Each sheet item has a unique identifier for tracking
/// - **Animation Control**: Items can specify whether they should be animated
/// - **Presentation Style**: Items define how they should be presented
/// - **Dismissal Lifecycle**: Items provide hooks for dismissal events
///
/// ## Example Implementation
/// ```swift
/// struct CustomSheetItem: SheetItemType {
///     let id: String
///     let willDismiss = PassthroughSubject<Void, Never>()
///     private let animated: Bool
///     private let style: TransitionPresentationStyle
///
///     init(id: String, animated: Bool, style: TransitionPresentationStyle) {
///         self.id = id
///         self.animated = animated
///         self.style = style
///     }
///
///     func isAnimated() -> Bool { animated }
///     func getPresentationStyle() -> TransitionPresentationStyle { style }
/// }
/// ```
protocol SheetItemType: SCEquatable {
    
    /// A string that uniquely identifies the sheet item.
    ///
    /// This identifier is used throughout the sheet management system to track,
    /// reference, and manage individual sheet items. It should be unique across
    /// all currently active sheet items.
    var id: String { get }
    
    /// A publisher that emits a void value just before the sheet is dismissed.
    ///
    /// This subject allows subscribers to perform cleanup or state updates before
    /// the sheet disappears from the screen. It's particularly useful for custom
    /// presentation styles that need to coordinate their dismissal timing.
    ///
    /// - Note: The subject emits once when dismissal begins, not when it completes.
    var willDismiss: PassthroughSubject<Void, Never> { get }
    
    /// Returns whether the sheet presentation should be animated.
    ///
    /// This method provides a consistent interface for accessing animation preferences
    /// across different sheet item implementations.
    ///
    /// - Returns: `true` if the sheet should be presented/dismissed with animation,
    ///            `false` for immediate presentation/dismissal without animation.
    func isAnimated() -> Bool
    
    /// Returns the transition presentation style for presenting the sheet item.
    ///
    /// This method provides access to the presentation style that determines how
    /// the sheet should be displayed (e.g., modal sheet, full screen cover, custom transition).
    ///
    /// - Returns: The `TransitionPresentationStyle` that defines how this sheet should be presented.
    func getPresentationStyle() -> TransitionPresentationStyle
}
