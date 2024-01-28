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
	 */
	func cleanView(
        animated: Bool = false,
        withMainView: Bool = true
    ) async {
		await router.clean(animated: animated, withMainView: withMainView)
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
	 */
	func removeChild(coordinator : TCoordinatorType) async {
		guard let index = children.firstIndex(where: {$0.uuid == coordinator.uuid}) else {
			return
		}
		children.remove(at: index)
		await coordinator.removeChildren()
        await removeChild(coordinator: coordinator)
	}
	
	/**
	 Removes all child coordinators associated with the current coordinator.
	 
	 - Parameters:
			- animated: A flag indicating whether the removal action should be animated.
	 */
	func removeChildren(animated: Bool = false) async {
		guard let first = children.first else { return }
		await first.handleFinish(animated: animated, withDissmis: false)
        await removeChildren()
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
	 */
	func dismissLastSheet(animated: Bool = true) async {
		await router.dismiss(animated: animated)
	}
	
	/**
	 Empties the current coordinator.
	 
	 - Parameters:
        - animated: A flag indicating whether the dismissal action should be animated.
	 */
	func emptyCoordinator(animated: Bool) async {
		guard let parent = parent else {
            await removeChildren()
            return await router.restart(animated: animated)
		}
		
		await parent.removeChild(coordinator: self)
        await cleanView(animated: false)
	}
	
	/**
	 Handles the finish action.
	 
	 - Parameters:
			- animated: A flag indicating whether the finish action should be animated.
			- withDissmis: A flag indicating whether the dismissal action should be included.
	 */
	func handleFinish(animated: Bool = true, withDissmis: Bool = true) async {
		guard withDissmis else {
            return await emptyCoordinator(animated: animated)
		}
		await router.close(animated: animated, finishFlow: true)
        await emptyCoordinator(animated: animated)
	}
    
    /**
     Finishes the coordinator.
     
     - Parameters:
            - animated: A flag indicating whether the finish action should be animated.
            - withDissmis: A flag indicating whether the dismissal action should be included.
     */
    func finish(
        animated: Bool = true,
        withDissmis: Bool = true
    ) async -> Void {
        let handleFinish = { (coordinator: TCoordinatorType) async -> Void in
            await coordinator.handleFinish(
                animated: animated,
                withDissmis: withDissmis
            )
        }
        
        if (parent is (any TabbarCoordinatable)) {
            await router.close(animated: animated, finishFlow: true)
            await handleFinish(parent)
        } else {
            await handleFinish(self)
        }
    }
}
