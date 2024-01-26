//
//  Navigator.swift
//  CRNavigation
//
//  Created by Andres Lozano on 1/12/23.
//

import Combine
import SwiftUI

/**
 A class representing a navigation router for coordinating the navigation flow within an application.

 The `NavigationRouter` class conforms to the `ObservableObject` and `RouterType` protocols, providing functionality for navigating between different views or coordinators.

 - Note: The router manages a stack of routes, a sheet coordinator, and various navigation actions.

 Example usage:
 ```swift
 // Create an instance of the NavigationRouter.
 let navigationRouter = NavigationRouter<MyRouteType>()

 // Use the navigationRouter to navigate to a specific route.
 navigationRouter.navigate(to: myRoute, animated: true)
*/
public class Router<Route: RouteType>: ObservableObject, RouterType {
	
	// --------------------------------------------------------------------
	// MARK: Wrapper Properties
	// --------------------------------------------------------------------
	
	/// The first view in the navigation flow.
	@Published public var mainView: Route?
	/// The array of routes managed by the navigation router.
	@Published public var items: [Route] = []
	// The sheet coordinator for presenting sheets.
	@Published public var sheetCoordinator: SheetCoordinator<Route.Body> = .init()
	
	// --------------------------------------------------------------------
	// MARK: Properties
	// --------------------------------------------------------------------
	
	/// The coordinator associated with the router.
	public var coordinator: (any CoordinatorType)?
	
	// --------------------------------------------------------------------
	// MARK: Constructor
	// --------------------------------------------------------------------
	
	/// Creates a new instance of the navigation router.
	public init() { }
	
	// --------------------------------------------------------------------
	// MARK: RouterType
	// --------------------------------------------------------------------
	
	/// Navigates to a specific route with the specified transition style and animation
	public func navigate(
		to route: Route,
        presentationStyle: TransitionPresentationStyle? = nil,
		animated: Bool = true,
		completion: Completion? = nil
	) -> Void {
		if (presentationStyle ?? route.presentationStyle) == .push {
			return runActionWithAnimation(animated) { [weak self] in
				self?.items.append(route)
                completion?()
			}
		}
		present(
			route, 
            presentationStyle: presentationStyle,
			animated: animated,
			completion: completion)
	}
	
	/// Presents a view with the specified transition style and animation settings.
	public func present(
		_ view: Route,
        presentationStyle: TransitionPresentationStyle? = .sheet,
		animated: Bool = true,
		completion: Completion? = nil
	) -> Void {
		
		if (presentationStyle ?? view.presentationStyle) == .push {
			return navigate(
				to: view,
                presentationStyle: presentationStyle,
				animated: animated,
				completion: completion)
		}
		
		let item = SheetItem(
            id: view.id,
			view: view.view,
			animated: animated,
            presentationStyle: presentationStyle ?? view.presentationStyle)
		
		presentSheet(item: item, completion: completion)
	}
	
	/// Pops the top view from the navigation stack.
	public func pop(animated: Bool, completion: Completion? = nil) -> Void {
		runActionWithAnimation(animated) { [weak self] in
			self?.handlePopAction()
			completion?()
		}
	}
	
	/// Pops to the root view in the navigation stack.
	public func popToRoot(animated: Bool = true, completion: Completion? = nil) -> Void {
		runActionWithAnimation(animated) { [weak self] in
			self?.items.removeAll()
			completion?()
		}
	}
	
	/// Pops to a specific view in the navigation stack.
	public func popToView<T>(
		_ view: T,
		animated: Bool = true,
		completion: ((Bool) -> Void)? = nil
	) -> Void {
		
		let name: (Any) -> String = { String(describing: $0.self) }
		guard let index = items.firstIndex(where: { name($0) == name(view) }) else {
			completion?(false)
			return
		}
        
        let position = index + 1
        
        if position >= items.count {
            completion?(true)
            return
        }
        
        let range = position..<items.count
		runActionWithAnimation(animated) { [weak self] in
            self?.items.remove(atOffsets: IndexSet.init(integersIn: range))
			completion?(true)
		}
	}
	
	/// Dismisses the top view or coordinator in the navigation stack.
	public func dismiss(animated: Bool = true, completion: Completion?) -> Void {
		runActionWithAnimation(animated) { [weak self] in
			self?.sheetCoordinator.removeLastSheet(animated: animated, action: completion)
		}
	}
	
	/// Closes the top view or coordinator in the navigation stack.
	public func close(animated: Bool = true, finishFlow: Bool = false, completion: Completion?) -> Void {
		if finishFlow {
			if let parent = coordinator?.parent {
				parent.dismissLastSheet(animated: animated, completion: completion)
			} else {
				completion?()
			}
			
		} else if sheetCoordinator.items.isEmpty {
			pop(animated: animated, completion: completion)
		} else {
			dismiss(animated: animated, completion: completion)
		}
	}
	
	/// Cleans up the navigation stack and associated views or coordinators.
    public func clean(animated: Bool, withMainView: Bool = true, completion: Completion? = nil) -> Void {
        runActionWithAnimation(animated) { [weak self] in
            self?.sheetCoordinator.clean(animated: animated) {
                self?.items = []
                self?.coordinator = nil
                if withMainView { self?.mainView = nil }
                completion?()
            }
        }
	}
	
	/// Restarts the navigation flow with the specified animation settings.
	public func restart(animated: Bool, completion: Completion? = nil) -> Void {
		popToRoot(animated: animated) { [weak self] in
			self?.sheetCoordinator.clean(animated: animated, action: completion)
		}
	}
	
	/// Presents a sheet with the specified item and completion action.
	func presentSheet(item: SheetItem<(any View)>, completion: Completion? = nil) {
        sheetCoordinator.presentSheet(item, animated: item.animated, action: completion)
	}
}


fileprivate extension Router {
	
	// --------------------------------------------------------------------
	// MARK: Helper funcs
	// --------------------------------------------------------------------
	
	/// Executes the specified action on the main thread.
	private func runInMainThread(_ action: @escaping Completion) {
		guard !Thread.isMainThread  else { return action() }
		DispatchQueue.main.async { action() }
	}
	
	/// Executes the specified action with animation based on the provided settings.
	private func runActionWithAnimation(_ animated: Bool, action: @escaping Completion ) {
		runInMainThread {
			var transaction = Transaction()
			transaction.disablesAnimations = !animated
			withTransaction(transaction) { action() }
		}
	}
	
	/// Handles the pop action by updating the navigation stack.
	private func handlePopAction() {
		guard !items.isEmpty else { return }
		items.removeLast()
	}
}
