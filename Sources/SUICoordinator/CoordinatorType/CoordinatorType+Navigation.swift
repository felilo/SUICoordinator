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

public extension CoordinatorType {
    
    /// Returns the coordinator that is currently visible to the user.
    ///
    /// The method first resolves the **top-most coordinator** in the hierarchy
    /// (starting from `customRootCoordinator` when provided, otherwise from
    /// `self`).  
    /// If that coordinator is embedded in a `TabCoordinatable`, the function
    /// asks the tab container which child coordinator is **selected** and
    /// returns it; otherwise it simply returns the discovered top coordinator.
    ///
    /// - Parameter customRootCoordinator: Optional starting point for the
    ///   traversal. Pass `nil` to start the search from `self`.
    /// - Returns: The `AnyCoordinatorType` that represents the screen currently
    ///   being presented, or `nil` when no coordinator could be found.
    /// - Throws: Propagates errors thrown by `topCoordinator(pCoordinator:)`,
    ///   usually indicating an invalid or missing hierarchy.
    func getCoordinatorPresented(customRootCoordinator: AnyCoordinatorType? = nil) throws -> AnyCoordinatorType? {
        let topCoordinator = try topCoordinator(pCoordinator: customRootCoordinator)
        if let tabCoordinator = topCoordinator?.parent as? (any TabCoordinatable) {
            return try tabCoordinator.getCoordinatorSelected()
        }
        return topCoordinator
    }
    
    /// Navigates to a new coordinator with a specified presentation style.
    ///
    /// This method handles coordinator-to-coordinator navigation by setting up the child relationship,
    /// creating the appropriate sheet item, and managing the presentation lifecycle.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator to navigate to. This coordinator will become a child
    ///                  of the current coordinator.
    ///   - presentationStyle: The transition presentation style for the navigation.
    ///                        Determines how the new coordinator's view will be presented.
    ///   - animated: A boolean value indicating whether to animate the navigation. Defaults to `true`.
    ///
    /// ## Example Usage
    /// ```swift
    /// let profileCoordinator = ProfileCoordinator()
    /// await currentCoordinator.navigate(
    ///     to: profileCoordinator,
    ///     presentationStyle: .sheet,
    ///     animated: true
    /// )
    /// ```
    func navigate(
        to coordinator: AnyCoordinatorType,
        presentationStyle: TransitionPresentationStyle,
        animated: Bool = true
    ) async -> Void {
        startChildCoordinator(coordinator)
        
        let item = buildSheetItemForCoordinator(coordinator, presentationStyle: presentationStyle, animated: animated)
        
        await swipedAway(coordinator: coordinator)
        await router.presentSheet(item: item)
    }
    
    
    /// Navigates to a destination described by a `Route`.
    ///
    /// This overload is handy when you only need to push or present a view and
    /// do not require the overhead of instantiating a dedicated coordinator.
    /// The call is forwarded to the underlying `router`, which will decide how
    /// to display the destination based on the supplied `presentationStyle`.
    ///
    /// - Parameters:
    ///   - route: The destination route to display.
    ///   - presentationStyle: Optionally override the router’s default
    ///     presentation style (e.g., `.push`, `.sheet`, `.fullScreenCover`).
    ///     Pass `nil` to let the router decide.
    ///   - animated: `true` to animate the transition. Defaults to `true`.
    ///
    /// ## Example
    /// ```swift
    /// await coordinator.navigate(
    ///     toRoute: ProfileRoute.details(userID: id),
    ///     presentationStyle: .sheet
    /// )
    /// ```
    func navigate(
        toRoute route: Route,
        presentationStyle: TransitionPresentationStyle? = nil,
        animated: Bool = true
    ) async -> Void {
        await router.navigate(toRoute: route, presentationStyle: presentationStyle, animated: animated)
    }
    
    /// Finishes the flow of the coordinator.
    ///
    /// This method cleanly terminates the coordinator's flow by performing cleanup operations
    /// and removing the coordinator from the hierarchy. It handles both dismissal and cleanup.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the finish flow process.
    ///               Defaults to `true`.
    ///
    /// ## Usage Notes
    /// - Call this method when a coordinator's purpose has been fulfilled
    /// - The coordinator will be removed from its parent's children array
    /// - Any presented views or sheets will be dismissed
    /// - Resources will be cleaned up automatically
    func finishFlow(animated: Bool = true) async -> Void {
        await finish(animated: animated, withDismiss: true)
    }
    
    /// Starts a flow in the coordinator with a specified route and transition style.
    ///
    /// This method initializes the coordinator's main view with the provided route,
    /// establishing the foundation for the coordinator's navigation flow.
    ///
    /// - Parameters:
    ///   - route: The route to start the flow with. This becomes the coordinator's main view.
    ///   - transitionStyle: The transition presentation style for the flow. Currently unused
    ///                      but reserved for future functionality.
    ///   - animated: A boolean value indicating whether to animate the start flow process.
    ///               Defaults to `true`.
    ///
    /// ## Example Usage
    /// ```swift
    /// await coordinator.startFlow(
    ///     route: HomeRoute.main,
    ///     transitionStyle: .push,
    ///     animated: true
    /// )
    /// ```
    
    @MainActor func startFlow(route: Route) async -> Void {
        if !isRunning { router.mainView = route }
    }
    
    /// Forces the presentation of the coordinator.
    ///
    /// This method provides a way to present a coordinator from anywhere in the hierarchy
    /// by finding the top coordinator and using it to present this coordinator.
    /// It's useful for global navigation operations or deep linking scenarios.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the presentation.
    ///               Defaults to `true`.
    ///   - presentationStyle: The transition presentation style for the forced presentation.
    ///                        Defaults to `.sheet`.
    ///   - rootCoordinator: The main coordinator from which to find the top coordinator.
    ///                      If `nil`, the operation may fail if no proper hierarchy exists.
    ///
    /// - Throws: An error if the presentation cannot be forced due to hierarchy issues
    ///           or if the top coordinator cannot be determined.
    ///
    /// ## Example Usage
    /// ```swift
    /// try await emergencyCoordinator.forcePresentation(
    ///     animated: true,
    ///     presentationStyle: .fullScreenCover,
    ///     rootCoordinator: appCoordinator
    /// )
    /// ```
    func forcePresentation(
        animated: Bool = true,
        presentationStyle: TransitionPresentationStyle = .sheet,
        rootCoordinator: (any CoordinatorType)? = nil
    ) async throws {
        let topCoordinator = try rootCoordinator?.topCoordinator()
        await topCoordinator?.navigate(to: self, presentationStyle: presentationStyle)
    }
    
    /// Restarts the current view or coordinator, optionally animating the restart.
    ///
    /// This method provides a way to reset the coordinator's navigation state,
    /// clearing all navigation stacks and modal presentations.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the restart action.
    ///               Defaults to `true`.
    ///
    /// ## Usage Notes
    /// - All navigation history will be lost
    /// - Modal presentations will be dismissed
    /// - The coordinator will return to its initial state
    /// - Useful for logout scenarios or major state changes
    func restart(animated: Bool = true) async {
        await router.restart(animated: animated)
    }
    
    /// Closes the current screen.
    ///
    /// The underlying `router` determines whether to dismiss a modal
    /// presentation or pop the current view from a navigation stack,
    /// depending on the active presentation context.
    ///
    /// - Parameter animated: `true` to animate the transition. Defaults to `true`.
    func close(animated: Bool = true) async {
        await router.close(animated: animated)
    }
}
