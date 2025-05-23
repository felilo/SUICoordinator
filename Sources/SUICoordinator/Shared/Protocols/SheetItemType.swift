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
/// This protocol ensures that any conforming type can provide necessary information
/// for sheet presentation, such as an identifier, animation preference, and presentation style.
protocol SheetItemType: SCEquatable {
    
    /// A `String` that uniquely identifies the sheet item.
    var id: String { get }
    
    /// A `PassthroughSubject` that emits a void value just before the sheet is dismissed.
    var willDismiss: PassthroughSubject<Void, Never> { get }
    
    /// A boolean value indicating whether to animate the presentation.
    func isAnimated() -> Bool
    
    /// The transition presentation style for presenting the sheet item.
    func getPresentationStyle() -> TransitionPresentationStyle
}
