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
    func finishFlow(animated: Bool, completion: Completion?) {
        finish(
            animated: animated,
            withDissmis: true,
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
