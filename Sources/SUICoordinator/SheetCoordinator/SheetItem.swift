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

/// A class representing a sheet item for presenting views or coordinators in a coordinator-based architecture.
///
/// Sheet items encapsulate information about the view, animation, and presentation style.
final public class SheetItem<T>: SCHashable {
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The unique identifier for the sheet item.
    public var id: String
    
    /// The view or coordinator associated with the sheet item.
    let view: T
    
    /// A boolean value indicating whether to animate the presentation.
    let animated: Bool
    
    /// The transition presentation style for presenting the sheet item.
    let presentationStyle: TransitionPresentationStyle
    
    // ---------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------
    
    /// Initializes a new instance of `SheetItem`.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the sheet item.
    ///   - view: The view or coordinator to present.
    ///   - animated: A boolean value indicating whether to animate the presentation.
    ///   - presentationStyle: The transition presentation style for presenting the sheet item.
    init(id: String = UUID().uuidString, view: T, animated: Bool, presentationStyle: TransitionPresentationStyle) {
        self.view = view
        self.animated = animated
        self.presentationStyle = presentationStyle
        self.id = id
    }
    
    // ---------------------------------------------------------
    // MARK: Deinitializer
    // ---------------------------------------------------------
    
    deinit {
        // Clean up the view if it conforms to CoordinatorViewType protocol.
        if let view = view as? CoordinatorViewType {
            view.clean()
        }
    }
}
