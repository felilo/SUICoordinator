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
@available(iOS 17.0, *)
@MainActor
public protocol RouterType: Observable, SCIdentifiable {

    // --------------------------------------------------------------------
    // MARK: Associated Type
    // --------------------------------------------------------------------

    /// The associated type representing the route associated with the router.
    associatedtype Route: RouteType

    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------

    /// The sheet coordinator associated with the router.
    var sheetCoordinator: SheetCoordinator<AnyViewAlias> { get }

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

    /// Clears the navigation stack and optionally removes the main view.
    ///
    /// - Parameters:
    ///   - animated: Whether to animate the operation.
    ///   - withMainView: Whether to also remove the main view from the stack.
    func clean(animated: Bool, withMainView: Bool) async -> Void

    /// Closes the current flow, dismissing the coordinator's presentation.
    ///
    /// - Parameter animated: Whether to animate the dismissal.
    func close(animated: Bool) async -> Void

    /// Restarts the router, resetting navigation state.
    ///
    /// - Parameter animated: Whether to animate the reset.
    func restart(animated: Bool) async -> Void

    /// Synchronises the router's items with the current navigation state.
    func syncItems() async -> Void

    /// Sets the main view of the router to the specified route.
    ///
    /// - Parameter view: The route to set as the main view, or `nil` to clear it.
    func setView(with view: Route?) async -> Void
}
