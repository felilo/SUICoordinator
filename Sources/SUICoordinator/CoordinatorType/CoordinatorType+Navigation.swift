//
//  CoordinatorType+Navigation.swift
//  CRNavigation
//
//  Created by Andres Lozano on 23/12/23.
//

import Foundation

public extension CoordinatorType {
	
	/**
	 Retrieves the top coordinator.
	 
	  - Parameters:
	 
			- pCoodinator: An optional parent coordinator.
	 - Returns: The type-erased top coordinator associated with the provided parent coordinator.
	 - Throws: An error if the top coordinator cannot be retrieved.
	 */
	func topCoordinator(pCoodinator: TCoordinatorType? = nil) throws -> TCoordinatorType? {
		guard children.last != nil else { return self }
		var auxCoordinator = pCoodinator ?? self.children.last
		return try getDeepCoordinator(from: &auxCoordinator)
	}
	
	/**
	 Navigates to a new coordinator.
	 
	- Parameters:
	       - coordinator: The type-erased coordinator to navigate to.
		   - transitionStyle: The transition style for the navigation.
		   - animated: A flag indicating whether the navigation should be animated.
		   - completion: A closure to be executed upon completion.
	 */
	func navigate(
		to coordinator: TCoordinatorType,
        presentationStyle: TransitionPresentationStyle,
		animated: Bool = true,
		completion: Completion? = nil
	) -> Void {
		startChildCoordinator(coordinator)
		
		let item = SheetItem(
			view: coordinator.view,
			animated: animated,
            presentationStyle: (presentationStyle != .push) ? presentationStyle :  .sheet)
		
		router.presentSheet(item: item, completion: completion)
	}
    
    /**
     Finishes the current flow.
     
        - Parameters:
            - animated: A flag indicating whether the finish action should be animated.
            - completion: A closure to be executed upon completion.
     */
    func finishFlow(animated: Bool, withDissmis: Bool = true, completion: Completion?) {
        finish(
            animated: animated,
            withDissmis: withDissmis,
            completion: completion)
    }
    
    
    /**
     Initiates the flow with a given route.
     
        - Parameters:
            - route: The route to start the flow.
            - transitionStyle: The transition style for the navigation. Default is nil.
            - animated: A flag indicating whether the navigation should be animated.
     */
    func startFlow(
        route: Route,
        transitionStyle: TransitionPresentationStyle? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        router.restart(animated: animated) { [weak self] in
            self?.router.mainView = route
            completion?()
        }
    }
}
