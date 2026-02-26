//
//  TransitionPresentationStyle.swift
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

/**
 Enum defining the transition styles for presentation in the Coordinator pattern.
 
 TransitionPresentationStyle enumerates the different styles used for transitioning between views or presenting views within an application.
 */
public enum TransitionPresentationStyle: @unchecked Sendable, SCEquatable {
    
    /// A push transition style, commonly used in navigation controllers.
    case push
    /// A sheet presentation style, often used for modal or overlay views.
    case sheet
    /// A full-screen cover presentation style.
    case fullScreenCover
    /// A style allowing for presenting views with specific detents.
    case detents(Set<PresentationDetent>)
    /// A custom presentation style.
    case custom(transition: AnyTransition, animation: Animation?, fullScreen: Bool = false)
    
    internal var isCustom: Bool {
        guard case .custom = self else { return false }
        
        return true
    }
}
