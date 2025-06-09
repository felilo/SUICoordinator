//
//  DefaultRoute.swift
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

/// A struct representing a default route with a specified presentation style and content view.
public struct DefaultRoute: RouteType {
    
    // ---------------------------------------------------------
    // MARK: - Properties
    // ---------------------------------------------------------
    
    /// The presentation style for the route transition.
    private let _presentationStyle: TransitionPresentationStyle
    
    /// The content view for the route.
    public var content: () -> (AnyViewAlias?)
    
    // ---------------------------------------------------------
    // MARK: - Constructor
    // ---------------------------------------------------------
    
    /// Initializes a new instance of `DefaultRoute`.
    ///
    /// - Parameters:
    ///   - presentationStyle: The presentation style for the route transition.
    ///   - content: The content view for the route.
    public init(
        presentationStyle: TransitionPresentationStyle,
        @ViewBuilder content: @escaping () -> AnyViewAlias?
    ) {
        self.content = content
        self._presentationStyle = presentationStyle
    }
    
    // ---------------------------------------------------------
    // MARK: - RouteNavigation
    // ---------------------------------------------------------
    
    /// The presentation style for the route transition.
    public var presentationStyle: TransitionPresentationStyle {
        _presentationStyle
    }
    
    public var body: some View {
        if let v = content() {
            v.asAnyView()
                .id(String(describing: v.self))
        }
    }
}
