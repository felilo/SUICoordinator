//
//  RouterType.swift
//  CRNavigation
//
//  Created by Andres Lozano on 4/12/23.
//

import Foundation
import Combine


/**
 Protocol defining the requirements for a router in the Coordinator pattern.
 
 Routers are responsible for handling the navigation and presentation of views within an application. They facilitate the coordination of flows and transitions between different parts of the app.
 
 Conforming types must provide an associated type `Route`, which represents the possible routes or navigation actions that the router can handle.
 */

public protocol RouterType: ObservableObject {
	
	// --------------------------------------------------------------------
	// MARK: Associatedtype
	// --------------------------------------------------------------------
	
	/// The associated type representing the possible routes or navigation actions that the router can handle.
	associatedtype Route: RouteType
	
	
	// --------------------------------------------------------------------
	// MARK: Properties
	// --------------------------------------------------------------------
	
	/// The coordinator associated with the router.
	var coordinator: (any CoordinatorType)? { get set }
	/// The collection of routes or views managed by the router.
	var items: [Route] { get set }
	// The sheet coordinator responsible for managing sheet presentations.
	var sheetCoordinator: SheetCoordinator<Route.Body> { get set }
	/// The initial view or route for the router.
	var mainView: Route? { get set }
	
	// --------------------------------------------------------------------
	// MARK: Funcs
	// --------------------------------------------------------------------
	
	/**
	 Navigates to a route.
	 
		- Parameters:
			- route: The route to navigate to.
			- transitionStyle: The transition style for the navigation. Default is nil.
			- animated: A flag indicating whether the navigation should be animated.
	 */
	func navigate(to route: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async
	
	/**
	 Presents a view.
	 
		- Parameters:
			- view: The view to be presented.
			- transitionStyle: The transition style for the presentation. Default is nil.
			- animated: A flag indicating whether the presentation should be animated.
	 */
	func present(_ view: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async
	
	/**
	 Pops the current view from the navigation stack.
	 
		- Parameters:
			- animated: A flag indicating whether the pop action should be animated.
	 */
	func pop(animated: Bool) async
	
	/**
	 Pops to the root view of the navigation stack.
	 
		- Parameters:
			- animated: A flag indicating whether the pop action should be animated.
	 */
	func popToRoot(animated: Bool) async
	
	/**
	 Pops to a specific view in the navigation stack.
	 
		- Parameters:
			- view: The view to which the navigation stack should be popped.
			- animated: A flag indicating whether the pop action should be animated.
	 */
	func popToView<T>(_ view: T, animated: Bool) async -> Bool
	
	/**
	 Dismisses the current view.
	 
		- Parameters:
			- animated: A flag indicating whether the dismissal action should be animated.
	 */
	func dismiss(animated: Bool) async
	
	/**
	 Cleans up the router's state.
	 
		- Parameters:
			- animated: A flag indicating whether the cleanup action should be animated.
	 */
	func clean(animated: Bool, withMainView: Bool) async -> Void
	
	/**
	 Closes the current view or flow.
	 
		- Parameters:
			- animated: A flag indicating whether the closing action should be animated.
			- finishFlow: A flag indicating whether to finish the current flow.
	 */
	func close(animated: Bool, finishFlow: Bool) async -> Void
	
	/**
	 Restarts the router.
	 
		- Parameters:
			- animated: A flag indicating whether the restart action should be animated.
	 */
	func restart(animated: Bool) async -> Void
}
