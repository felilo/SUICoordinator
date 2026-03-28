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

/// A protocol representing a router in the coordinator pattern.
///
/// Routers manage the navigation stack and sheet presentations within a coordinator.
/// They act as the bridge between the coordinator's business logic and the SwiftUI
/// view hierarchy, handling push navigation, modal presentations, and dismissals.
///
/// `RouterType` is a primary associated type protocol, so you can write
/// `any RouterType<MyRoute>` to refer to an existential router bound to a specific route type.
///
/// - Important: `Route` must conform to `RouteType`, which requires `Hashable`, `Sendable`,
///   and SwiftUI's `View` protocol. This ensures routes can be safely used in `NavigationStack`
///   and passed across async concurrency boundaries.
@available(iOS 17.0, *)
@MainActor
public protocol RouterType<Route>: Observable, SCIdentifiable, AnyObject {

    // --------------------------------------------------------------------
    // MARK: Associated Type
    // --------------------------------------------------------------------

    /// The route type managed by this router.
    ///
    /// Must conform to `RouteType`, which requires `Hashable` (for `NavigationStack`),
    /// `Sendable` (for safe async use), and SwiftUI's `View` (each route renders its own UI).
    associatedtype Route: RouteType

    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------

    /// A Boolean indicating whether navigation transitions are animated.
    var animated: Bool { get }

    // --------------------------------------------------------------------
    // MARK: Functions
    // --------------------------------------------------------------------

    /// Navigates to the specified route using the given presentation style.
    ///
    /// - Parameters:
    ///   - route: The route to navigate to.
    ///   - presentationStyle: The transition style to use, or `nil` to use the route's default.
    ///   - animated: Whether to animate the transition.
    func navigate(toRoute route: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async

    /// Presents the specified route as a modal.
    ///
    /// - Parameters:
    ///   - view: The route to present.
    ///   - presentationStyle: The transition style to use, or `nil` to use the route's default.
    ///   - animated: Whether to animate the presentation.
    func present(_ view: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async

    /// Pops the top view from the navigation stack.
    ///
    /// - Parameter animated: Whether to animate the transition.
    func pop(animated: Bool) async

    /// Pops all views back to the root of the navigation stack.
    ///
    /// - Parameter animated: Whether to animate the transition.
    func popToRoot(animated: Bool) async

    /// Dismisses the currently presented modal.
    ///
    /// - Parameter animated: Whether to animate the dismissal.
    func dismiss(animated: Bool) async

    /// Closes the current flow, dismissing the coordinator's presentation.
    ///
    /// - Parameter animated: Whether to animate the dismissal.
    func close(animated: Bool) async -> Void

    /// Restarts the router, resetting navigation state.
    ///
    /// - Parameter animated: Whether to animate the reset.
    func restart(animated: Bool) async -> Void
}

@available(iOS 17.0, *)
public extension RouterType {
    
    // --------------------------------------------------------------------
    // MARK: Helpers func
    // --------------------------------------------------------------------
    
    /// Removes a specific item at the given index from the sheet coordinator.
    ///
    /// - Parameter index: The index of the item to remove.
    func navigate(toRoute route: Route, presentationStyle: TransitionPresentationStyle? = nil, animated: Bool = true) async {
        await navigate(toRoute: route, presentationStyle: presentationStyle, animated: animated)
    }
    
    func present(_ view: Route, presentationStyle: TransitionPresentationStyle? = nil, animated: Bool = true) async {
        await present(view, presentationStyle: presentationStyle, animated: animated)
    }
    
    /// Pops the top view from the navigation stack.
    ///
    /// - Parameter animated: Whether to animate the transition.
    func pop(animated: Bool = true) async {
        await pop(animated: animated)
    }
    
    /// Pops all views back to the root of the navigation stack.
    ///
    /// - Parameter animated: Whether to animate the transition.
    func popToRoot(animated: Bool = true) async {
        await popToRoot(animated: animated)
    }
    
    /// Dismisses the currently presented modal.
    ///
    /// - Parameter animated: Whether to animate the dismissal.
    func dismiss(animated: Bool = true) async {
        await dismiss(animated: animated)
    }
    
    /// Closes the current flow, dismissing the coordinator's presentation.
    ///
    /// - Parameter animated: Whether to animate the dismissal.
    func close(animated: Bool = true) async -> Void {
        await close(animated: animated)
    }
}
