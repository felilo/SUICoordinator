//
//  RouterType.swift
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

/// A protocol representing a router in the coordinator pattern.
public protocol RouterType: ObservableObject {
    
    // --------------------------------------------------------------------
    // MARK: Associated Type
    // --------------------------------------------------------------------
    
    /// The associated type representing the route associated with the router.
    associatedtype Route: RouteType
    
    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------
    
    /// An array of route items associated with the router.
    var items: [Route] { get set }
    
    /// The sheet coordinator associated with the router.
    var sheetCoordinator: SheetCoordinator<AnyViewAlias> { get }
    
    /// The main view associated with the router.
    var mainView: Route? { get }
    
    /// The main view associated with the router.
    var animated: Bool { get }
    
    // --------------------------------------------------------------------
    // MARK: Functions
    // --------------------------------------------------------------------
    
    @MainActor func navigate(toRoute route: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async
    @MainActor func present(_ view: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async
    @MainActor func pop(animated: Bool) async
    @MainActor func popToRoot(animated: Bool) async
    @MainActor func dismiss(animated: Bool) async
    func clean(animated: Bool, withMainView: Bool) async -> Void
    @MainActor func close(animated: Bool) async -> Void
    func restart(animated: Bool) async -> Void
    func syncItems() async -> Void
}
