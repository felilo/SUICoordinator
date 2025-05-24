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
    
    /// Retrieves the top coordinator in the hierarchy, optionally starting from a specified coordinator.
    ///
    /// This method traverses the coordinator hierarchy to find the deepest active coordinator,
    /// which is typically the one currently handling user interactions. It's useful for
    /// determining where new navigation operations should be performed.
    ///
    /// - Parameters:
    ///   - pCoodinator: The optional starting point for finding the top coordinator.
    ///                  If `nil`, starts from the last child of the current coordinator.
    ///
    /// - Returns: The top coordinator in the hierarchy, or `nil` if none is found.
    /// - Throws: An error if the top coordinator retrieval fails due to hierarchy issues.
    ///
    /// ## Example Usage
    /// ```swift
    /// if let topCoordinator = try coordinator.topCoordinator() {
    ///     await topCoordinator.navigate(to: newCoordinator, presentationStyle: .sheet)
    /// }
    /// ```
    func topCoordinator(pCoodinator: TCoordinatorType? = nil) throws -> TCoordinatorType? {
        guard children.last != nil else { return self }
        var auxCoordinator = pCoodinator ?? self.children.last
        return try getDeepCoordinator(from: &auxCoordinator)
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
        to coordinator: TCoordinatorType,
        presentationStyle: TransitionPresentationStyle,
        animated: Bool = true
    ) async -> Void {
        startChildCoordinator(coordinator)
        
        let item = buildSheetItemForCoordinator(coordinator, presentationStyle: presentationStyle, animated: animated)
        
        await swipedAway(coordinator: coordinator)
        await router.presentSheet(item: item)
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
    func startFlow(route: Route, transitionStyle: TransitionPresentationStyle? = nil, animated: Bool = true) async -> Void {
        router.mainView = route
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
    ///   - mainCoordinator: The main coordinator from which to find the top coordinator.
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
    ///     mainCoordinator: appCoordinator
    /// )
    /// ```
    func forcePresentation(
        animated: Bool = true,
        presentationStyle: TransitionPresentationStyle = .sheet,
        mainCoordinator: (any CoordinatorType)? = nil
    ) async throws {
        let topCoordinator = try mainCoordinator?.topCoordinator()
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
}
