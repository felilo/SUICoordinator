//
//  SheetItem.swift
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

/// A structure representing a sheet item for presenting views or coordinators in a coordinator-based architecture.
///
/// `SheetItem` encapsulates all the necessary information for presenting content modally,
/// including the view/coordinator to present, animation preferences, presentation style,
/// and lifecycle management.
///
/// Sheet items are used by sheet coordinators to manage modal presentations in a structured way,
/// providing consistent behavior and proper cleanup when sheets are dismissed.
///
/// ## Key Features
/// - Supports both SwiftUI views and coordinators
/// - Configurable presentation styles and animation
/// - Built-in dismissal lifecycle management
/// - Type-safe view/coordinator handling
public struct SheetItem<T>:SCEquatable, SheetItemType {
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The unique identifier for the sheet item.
    ///
    /// This identifier is used to track and manage the sheet item throughout its lifecycle.
    /// It enables proper identification when multiple sheets are managed simultaneously.
    public let id: String
    
    /// The view or coordinator factory associated with the sheet item.
    ///
    /// This closure creates and returns the content to be presented in the sheet.
    /// It can return either a SwiftUI view or a coordinator, depending on the generic type `T`.
    ///
    /// - Returns: The view or coordinator to present, or `nil` if creation fails.
    let view: () -> T?
    
    /// A boolean value indicating whether to animate the presentation.
    ///
    /// When `true`, the sheet will be presented with animation.
    /// When `false`, the presentation will occur without animation.
    let animated: Bool
    
    /// The transition presentation style for presenting the sheet item.
    ///
    /// This determines how the sheet is presented (e.g., `.sheet`, `.fullScreenCover`, etc.).
    /// The presentation style affects the visual appearance and behavior of the modal presentation.
    let presentationStyle: TransitionPresentationStyle
    
    /// A subject that emits when the sheet is about to be dismissed.
    ///
    /// This publisher allows observers to react to sheet dismissal events,
    /// enabling cleanup operations or state updates before the sheet disappears.
    let willDismiss: PassthroughSubject<Void, Never> = .init()
    
    /// A boolean value indicating whether the sheet item contains a coordinator.
    ///
    /// This flag helps the sheet management system determine how to handle the content,
    /// as coordinators may require different lifecycle management than regular views.
    let isCoordinator: Bool
    
    // ---------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------
    
    /// Initializes a new instance of `SheetItem`.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the sheet item. Should be unique across all active sheets.
    ///   - animated: A boolean value indicating whether to animate the presentation. Defaults to appropriate value based on context.
    ///   - presentationStyle: The transition presentation style for presenting the sheet item.
    ///   - isCoordinator: A boolean indicating whether the content is a coordinator. Defaults to `false`.
    ///   - view: A closure that creates and returns the view or coordinator to present.
    ///
    /// - Important: The `view` closure should be lightweight and avoid expensive operations,
    ///              as it may be called multiple times during the sheet's lifecycle.
    init(
        id: String,
        animated: Bool,
        presentationStyle: TransitionPresentationStyle,
        isCoordinator: Bool = false,
        view: @escaping () -> T?
    ) {
        self.view = view
        self.animated = animated
        self.presentationStyle = presentationStyle
        self.id = id
        self.isCoordinator = isCoordinator
    }
    
    // ---------------------------------------------------------
    // MARK: SheetItemType Conformance
    // ---------------------------------------------------------
    
    /// Returns the presentation style for this sheet item.
    ///
    /// This method provides access to the presentation style in a consistent way
    /// across different sheet item implementations.
    ///
    /// - Returns: The `TransitionPresentationStyle` configured for this sheet item.
    func getPresentationStyle() -> TransitionPresentationStyle {
        presentationStyle
    }
    
    /// Returns whether the sheet presentation should be animated.
    ///
    /// This method provides access to the animation preference in a consistent way
    /// across different sheet item implementations.
    ///
    /// - Returns: `true` if the presentation should be animated, `false` otherwise.
    func isAnimated() -> Bool {
        animated
    }
}
