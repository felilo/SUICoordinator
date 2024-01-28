//
//  Router.swift
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
    @MainActor public func navigate(
		to route: Route,
        presentationStyle: TransitionPresentationStyle? = nil,
		animated: Bool = true
	) async -> Void {
		if (presentationStyle ?? route.presentationStyle) == .push {
			return await runActionWithAnimation(animated) { [weak self] in
                return { self?.items.append(route) }
			}
		}
		await present(
			route, 
            presentationStyle: presentationStyle,
			animated: animated)
	}
	
	/// Presents a view with the specified transition style and animation settings.
    @MainActor public func present(
		_ view: Route,
        presentationStyle: TransitionPresentationStyle? = .sheet,
		animated: Bool = true
	) async -> Void {
		
		if (presentationStyle ?? view.presentationStyle) == .push {
			return await navigate(
				to: view,
                presentationStyle: presentationStyle,
				animated: animated)
		}
		
		let item = SheetItem(
            id: view.id,
			view: view.view,
			animated: animated,
            presentationStyle: presentationStyle ?? view.presentationStyle)
		
        await presentSheet(item: item)
	}
	
	/// Pops the top view from the navigation stack.
    @MainActor public func pop(animated: Bool) async -> Void {
        await runActionWithAnimation(animated) { [weak self] in
            return { self?.handlePopAction() }
		}
	}
	
	/// Pops to the root view in the navigation stack.
    @MainActor public func popToRoot(animated: Bool = true) async -> Void {
		await runActionWithAnimation(animated) { [weak self] in
            return { self?.items.removeAll() }
		}
	}
	
	/// Pops to a specific view in the navigation stack.
    @MainActor public func popToView<T>(_ view: T, animated: Bool = true) async -> Bool {
		let name: (Any) -> String = { String(describing: $0.self) }
        guard let index = items.firstIndex(where: { name($0) == name(view) }) else { return false }
        
        let position = index + 1
        let range = position..<items.count
        if position >= items.count { return true }
        
		await runActionWithAnimation(animated) { [weak self] in
            return { self?.items.remove(atOffsets: IndexSet.init(integersIn: range)) }
		}
        
        return true
	}
	
	/// Dismisses the top view or coordinator in the navigation stack.
    @MainActor public func dismiss(animated: Bool = true) async -> Void {
		await runActionWithAnimation(animated) { [weak self] in
			await self?.sheetCoordinator.removeLastSheet(animated: animated)
            return { }
		}
	}
	
	/// Closes the top view or coordinator in the navigation stack.
    @MainActor public func close(animated: Bool = true, finishFlow: Bool = false) async -> Void {
		if finishFlow {
			if let parent = coordinator?.parent {
				await parent.dismissLastSheet(animated: animated)
			}
			
		} else if sheetCoordinator.items.isEmpty {
            await pop(animated: animated)
		} else {
			await dismiss(animated: animated)
		}
	}
	
	/// Cleans up the navigation stack and associated views or coordinators.
    @MainActor public func clean(animated: Bool, withMainView: Bool = true) async -> Void {
        await runActionWithAnimation(animated) { [weak self] in
            await self?.sheetCoordinator.clean(animated: animated)
            return { 
                self?.items = []
                self?.coordinator = nil
                if withMainView { self?.mainView = nil }
            }
        }
	}
	
	/// Restarts the navigation flow with the specified animation settings.
    @MainActor public func restart(animated: Bool) async -> Void {
		await popToRoot(animated: animated)
        await sheetCoordinator.clean(animated: animated)
	}
	
	/// Presents a sheet with the specified item and completion action.
    @MainActor func presentSheet(item: SheetItem<(any View)>) async -> Void {
        await sheetCoordinator.presentSheet(item, animated: item.animated)
	}
}


fileprivate extension Router {
	
	// --------------------------------------------------------------------
	// MARK: Helper funcs
	// --------------------------------------------------------------------
	
	/// Executes the specified action with animation based on the provided settings.
    @MainActor private func runActionWithAnimation(_ animated: Bool, action: @escaping () async -> (() -> Void) ) async {
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        let customAction = await action()
        withTransaction(transaction, customAction)
	}
	
	/// Handles the pop action by updating the navigation stack.
	private func handlePopAction() {
		guard !items.isEmpty else { return }
		items.removeLast()
	}
}
