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

extension CoordinatorType {
	
	var root: (any RouterType) {
		return router
	}
	
	/// A Boolean value indicating whether the coordinator is TabbarCoordinatable.
	var isTabbarCoordinable: Bool {
		self is (any TabbarCoordinatable)
	}
	
	/**
	 Clean the views associated with the coordinator.
	 
	 - Parameters:
			- animated: A flag indicating whether the empty action should be animated.
			- completion: A closure to be executed upon completion.
	 */
	func cleanView(
        animated: Bool = false,
        withMainView: Bool = true,
        completion: Completion? = nil
    ) {
		router.clean(animated: animated, withMainView: withMainView, completion: completion)
		parent = nil
	}
	
	/**
	 Retrieves the deep coordinator from a given value.
	 
	 - Parameters:
			- value: An inout parameter representing the value of the coordinator.
	 
	 - Returns: The type-erased coordinator obtained from the provided value.
	 
	 - Throws: An error if the coordinator cannot be retrieved.
	 */
	func getDeepCoordinator(from value: inout TCoordinatorType?) throws -> TCoordinatorType? {
		if value?.children.last == nil {
			return value
		} else if let value = value, let tabCoordinator = getTabbarCoordinable(value) {
			return try topCoordinator(pCoodinator: try tabCoordinator.getCoordinatorSelected())
		} else {
			var last = value?.children.last
			return try getDeepCoordinator(from: &last)
		}
	}
	
	/**
	 Removes a child coordinator from the current coordinator.
	 
	 - Parameters:
			- coordinator: The type-erased coordinator to be removed.
			- completion: A closure to be executed upon completion.
	 */
	func removeChild(coordinator : TCoordinatorType, completion: Completion? = nil) {
		guard let index = children.firstIndex(where: {$0.uuid == coordinator.uuid}) else {
			completion?()
			return
		}
		children.remove(at: index)
		coordinator.removeChildren { [weak self] in
			self?.removeChild(coordinator: coordinator, completion: completion)
		}
	}
	
	/**
	 Removes all child coordinators associated with the current coordinator.
	 
	 - Parameters:
			- animated: A flag indicating whether the removal action should be animated.
			- completion: A closure to be executed upon completion.
	 */
	func removeChildren(animated: Bool = false, _ completion: Completion? = nil){
		guard let first = children.first else {
			completion?()
			return
		}
		first.handleFinish(animated: animated, withDissmis: false) { [weak self] in
			self?.removeChildren(completion)
		}
	}
	
	/**
	 Retrieves the TabbarCoordinatable from the given coordinator.
	 
	 - Parameters:
	 
		- coordinator: The type-erased coordinator from which to retrieve the TabbarCoordinatable.
	 - Returns: The TabbarCoordinatable associated with the provided coordinator.
	 
	 Note: Returns nil if the coordinator is not TabbarCoordinatable.
	 */
	func getTabbarCoordinable(_ coordinator: TCoordinatorType) ->  (any TabbarCoordinatable)? {
		coordinator as? (any TabbarCoordinatable)
	}
	
	/**
	 Starts a child coordinator.
	 
	 - Parameters:
			- coordinator: The type-erased coordinator to be started as a child.
	 */
	func startChildCoordinator(_ coordinator: TCoordinatorType) {
		children.append(coordinator)
		coordinator.parent = self
	}
	
	/**
	 Dismisses the last presented sheet.
	 
	 - Parameters:
			- animated: A flag indicating whether the dismissal action should be animated.
			- completion: A closure to be executed upon completion.
	 */
	func dismissLastSheet(animated: Bool = true, completion: Completion? = nil) {
		router.dismiss(animated: animated, completion: completion)
	}
	
	/**
	 Empties the current coordinator.
	 
	 - Parameters:
			- completion: A closure to be executed upon completion.
	 */
	func emptyCoordinator(animated: Bool, completion: Completion?) {
		guard let parent = parent else {
            return removeChildren() { [weak self] in
                self?.router.restart(animated: animated, completion: completion)
            }
		}
		
		parent.removeChild(coordinator: self) { [weak self] in
			self?.cleanView(animated: false, completion: completion)
		}
	}
	
	/**
	 Handles the finish action.
	 
	 - Parameters:
			- animated: A flag indicating whether the finish action should be animated.
			- withDissmis: A flag indicating whether the dismissal action should be included.
			- completion: A closure to be executed upon completion.
	 */
	func handleFinish(animated: Bool = true, withDissmis: Bool = true, completion: Completion?) {
		guard withDissmis else {
            return emptyCoordinator(animated: animated, completion: completion)
		}
		router.close(animated: animated, finishFlow: true) { [weak self] in
            self?.emptyCoordinator(animated: animated, completion: completion)
		}
	}
    
    /**
     Finishes the coordinator.
     
     - Parameters:
            - animated: A flag indicating whether the finish action should be animated.
            - withDissmis: A flag indicating whether the dismissal action should be included.
            - completion: A closure to be executed upon completion.
     */
    func finish(
        animated: Bool = true,
        withDissmis: Bool = true,
        completion: Completion?
    ) -> Void {
        let handleFinish: (TCoordinatorType) -> Void = { coordinator in
            coordinator.handleFinish(
                animated: animated,
                withDissmis: withDissmis,
                completion: completion
            )
        }
        
        if (parent is (any TabbarCoordinatable)) {
            router.close(animated: animated, finishFlow: true) { handleFinish(self.parent) }
        } else {
            handleFinish(self)
        }
    }
}
