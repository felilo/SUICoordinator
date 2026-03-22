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

/// A protocol that defines the requirements for a sheet item in the sheet coordinator system.
///
/// Types conforming to `SheetItemType` represent items that can be presented as modal sheets,
/// full-screen covers, or custom transitions. They provide the necessary information for
/// proper sheet lifecycle management.
public protocol SheetItemType: Identifiable {
    
    /// The unique string identifier for the sheet item.
    var id: String { get }
    
    /// A subject that emits when the sheet is about to be dismissed.
    ///
    /// Custom transition views subscribe to this subject to react to
    /// programmatic dismissal requests.
    var willDismiss: PassthroughSubject<Void, Never> { get }
    
    /// Returns whether the sheet presentation should be animated.
    func isAnimated() -> Bool
    
    /// Returns the presentation style for this sheet item.
    func getPresentationStyle() -> TransitionPresentationStyle
    
    var isCoordinator: Bool { get }
}
