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
	// MARK: Typealias
	// --------------------------------------------------------------------
	
	/// A closure type representing an action to be executed upon completion.
	typealias Completion = () -> Void
	
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
			- completion: A closure to be executed upon completion.
	 */
	func navigate(to route: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool, completion: Completion?)
	
	/**
	 Presents a view.
	 
		- Parameters:
			- view: The view to be presented.
			- transitionStyle: The transition style for the presentation. Default is nil.
			- animated: A flag indicating whether the presentation should be animated.
			- completion: A closure to be executed upon completion.
	 */
	func present(_ view: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool, completion: Completion?)
	
	/**
	 Pops the current view from the navigation stack.
	 
		- Parameters:
			- animated: A flag indicating whether the pop action should be animated.
			- completion: A closure to be executed upon completion.
	 */
	func pop(animated: Bool, completion: Completion?)
	
	/**
	 Pops to the root view of the navigation stack.
	 
		- Parameters:
			- animated: A flag indicating whether the pop action should be animated.
			- completion: A closure to be executed upon completion.
	 */
	func popToRoot(animated: Bool, completion: Completion?)
	
	/**
	 Pops to a specific view in the navigation stack.
	 
		- Parameters:
			- view: The view to which the navigation stack should be popped.
			- animated: A flag indicating whether the pop action should be animated.
			- completion: A closure to be executed upon completion.
	 */
	func popToView<T>(_ view: T, animated: Bool, completion: ((Bool) -> Void)?) -> Void
	
	/**
	 Dismisses the current view.
	 
		- Parameters:
			- animated: A flag indicating whether the dismissal action should be animated.
			- completion: A closure to be executed upon completion.
	 */
	func dismiss(animated: Bool, completion: Completion?)
	
	/**
	 Cleans up the router's state.
	 
		- Parameters:
			- animated: A flag indicating whether the cleanup action should be animated.
			- completion: A closure to be executed upon completion.
	 */
	func clean(animated: Bool, withMainView: Bool, completion: Completion?) -> Void
	
	/**
	 Closes the current view or flow.
	 
		- Parameters:
			- animated: A flag indicating whether the closing action should be animated.
			- finishFlow: A flag indicating whether to finish the current flow.
			- completion: A closure to be executed upon completion.
	 */
	func close(animated: Bool, finishFlow: Bool, completion: Completion?) -> Void
	
	/**
	 Restarts the router.
	 
		- Parameters:
			- animated: A flag indicating whether the restart action should be animated.
			- completion: A closure to be executed upon completion.
	 */
	func restart(animated: Bool, completion: Completion?) -> Void
}
