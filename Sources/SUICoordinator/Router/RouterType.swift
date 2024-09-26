//
//  RouterType.swift
//  CRNavigation
//
//  Created by Andres Lozano on 4/12/23.
//

import Foundation
import Combine


/// A protocol representing a router in the coordinator pattern.
///
/// Routers are responsible for the actual navigation and presentation of
/// views or coordinators within a coordinator-based architecture.
@available(iOS 16.0, *)
public protocol RouterType: ObservableObject {
    
    // --------------------------------------------------------------------
    // MARK: Associated Type
    // --------------------------------------------------------------------
    
    /// The associated type representing the route associated with the router.
    associatedtype Route: RouteType
    
    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------
    
    /// The coordinator associated with the router.
    var coordinator: (any CoordinatorType)? { get set }
    
    /// An array of route items associated with the router.
    var items: [Route] { get set }
    
    /// The sheet coordinator associated with the router.
    var sheetCoordinator: SheetCoordinator<Route.Body> { get set }
    
    /// The main view associated with the router.
    var mainView: Route? { get set }
    
    // --------------------------------------------------------------------
    // MARK: Functions
    // --------------------------------------------------------------------
    
    /// Navigates to a specified route with optional presentation style and animation.
    ///
    /// - Parameters:
    ///   - route: The route to navigate to.
    ///   - presentationStyle: The transition presentation style for the navigation.
    ///   - animated: A boolean value indicating whether to animate the navigation.
    func navigate(to route: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async
    
    /// Presents a view or coordinator with optional presentation style and animation.
    ///
    /// - Parameters:
    ///   - view: The view or coordinator to present.
    ///   - presentationStyle: The transition presentation style for the presentation.
    ///   - animated: A boolean value indicating whether to animate the presentation.
    func present(_ view: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async
    
    /// Pops the top view or coordinator from the navigation stack.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the pop action.
    func pop(animated: Bool) async
    
    /// Pops to the root of the navigation stack.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the pop action.
    func popToRoot(animated: Bool) async
    
    /// Pops to a specific view or coordinator in the navigation stack.
    ///
    /// - Parameters:
    ///   - view: The target view or coordinator to pop to.
    ///   - animated: A boolean value indicating whether to animate the pop action.
    /// - Returns: A boolean value indicating whether the pop action was successful.
    func popToView<T>(_ view: T, animated: Bool) async -> Bool
    
    /// Dismisses the currently presented view or coordinator.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the dismissal.
    func dismiss(animated: Bool)
    
    /// Cleans up the current view or coordinator, optionally preserving the main view.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the cleanup process.
    ///   - withMainView: A boolean value indicating whether to clean the main view.
    func clean(animated: Bool, withMainView: Bool) -> Void
    
    /// Closes the current view or coordinator, optionally finishing the associated flow.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the closing action.
    ///   - finishFlow: A boolean value indicating whether to finish the associated flow.
    func close(animated: Bool, finishFlow: Bool) async -> Void
    
    /// Restarts the current view or coordinator, optionally animating the restart.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the restart action.
    func restart(animated: Bool) async -> Void
}

@available(iOS 16.0, *)
extension RouterType {
    
    @MainActor func removeNilItemsFromSheetCoordinator() -> Void {
        sheetCoordinator.removeAllNilItems()
    }
    
    @MainActor func removeItemFromSheetCoordinator(at index: Int) -> Void {
        sheetCoordinator.remove(at: index)
    }
    
    var isTabbarCoordinable: Bool {
        coordinator?.isTabbarCoordinable == true
    }
}
