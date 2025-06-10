//
//  CoordinatorType.swift
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

/// A protocol representing a coordinator in the coordinator pattern.
///
/// Coordinators are responsible for the navigation flow and business logic
/// of a specific module or feature in an application.
///
/// - Important: Adopt this protocol in your custom coordinator implementations.
@MainActor
public protocol CoordinatorType: SCHashable, ObservableObject {
    
    // ---------------------------------------------------------
    // MARK: Associated Type
    // ---------------------------------------------------------
    
    /// The associated type representing the route associated with the coordinator.
    associatedtype Route: RouteType
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The unique identifier for the coordinator.
    var uuid: String { get set }
    
    /// An optional tag identifier for additional context or identification.
    var tagId: String? { get set }
    
    /// The parent coordinator, if any, to which this coordinator is a child.
    var parent: AnyCoordinatorType! { get set }
    
    /// An array of child coordinators associated with this coordinator.
    var children: [AnyCoordinatorType] { get set }
    
    /// The router responsible for navigation within the coordinator.
    var router: Router<Route> { get set }
    
    // ---------------------------------------------------------
    // MARK: Helper Functions
    // ---------------------------------------------------------
    
    /// Start the coordinator, triggering the initial navigation or setup.
    ///
    /// - Parameters:
    ///   - animated: A Boolean value indicating whether to animate the start transition.
    /// - Returns: An asynchronous void task representing the start process.
    func start() async -> Void
}
