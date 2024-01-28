//
//  RouteType.swift
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
 Protocol defining the requirements for a route in the Coordinator pattern.
 
 Routes represent the different views or navigation actions that can be handled by a coordinator or router within an application.
 
 Conforming types must provide a type alias `Body`, which represents the body of the route and conforms to the `View` protocol.
 */
public protocol RouteType: SCHashable {
    
    // ---------------------------------------------------------
    // MARK: typealias
    // ---------------------------------------------------------
    
    /// A type alias representing the body of the route, conforming to the View protocol.
    typealias Body = (any View)
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The transition style for presenting the view.
    var presentationStyle: TransitionPresentationStyle { get }
    
    /// The body of the route, conforming to the View protocol.
    @ViewBuilder var view: Body { get }
}
