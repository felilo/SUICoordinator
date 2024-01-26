//
//  SheetCoordinator.swift
//  DemoRootComposition
//
//  Created by Andres Lozano on 28/11/23.
//

import Foundation
import SwiftUI


/**
 A class representing a sheet coordinator in the Coordinator pattern.

 SheetCoordinator manages the presentation and removal of sheet views within an application. It facilitates the coordination of sheet presentations and provides methods for managing the sheet stack.

 Example usage:
 ```swift
 let sheetCoordinator = SheetCoordinator<MyViewType>()
 sheetCoordinator.presentSheet(mySheetItem, animated: true) {
	 // Completion block after presenting the sheet
 }
 */
final public class SheetCoordinator<T>: ObservableObject {
	
	// ---------------------------------------------------------
	// MARK: typealias
	// ---------------------------------------------------------
	
	/// A type alias representing the sheet item containing a view conforming to the `View` protocol.
	public typealias Item = SheetItem<T>
	
	/// A type alias representing a closure type for actions to be executed.
	public typealias Completion = () -> Void
	
	// ---------------------------------------------------------
	// MARK: Properties
	// ---------------------------------------------------------
	
	/// The stack of sheet items managed by the coordinator.
	@Published var items: [Item?]
	
	/// A flag indicating whether the coordinator is in the process of cleaning up.
	private var isCleaning: Bool = false
	
	/// The presentation style of the last presented sheet.
	public private (set) var lastPresentationStyle: TransitionPresentationStyle?
	
	// ---------------------------------------------------------
	// MARK: Constructor
	// ---------------------------------------------------------
	
	/**
		 Initializes a new sheet coordinator conforming to this protocol.

		 Example usage:
		 ```swift
		 let sheetCoordinator: SheetCoordinator = MySheetCoordinator()
		 ```

		 - Note: The `init` method initializes the sheet coordinator with an empty stack of sheet items.
	*/
	public init() {
		items = []
	}
	
	// ---------------------------------------------------------
	// MARK: Computed vars
	// ---------------------------------------------------------
	
	/// The total number of sheet items in the stack.
	var totalItems: Int {
		items.count - 1
	}
	
	// ---------------------------------------------------------
	// MARK: Helper funcs
	// ---------------------------------------------------------
	
	/**
		 Presents a sheet with the specified item asynchronously.

		 Example usage:
		 ```swift
		 sheetCoordinator.presentSheet(mySheetItem, animated: true) {
			 // Completion block after presenting the sheet
		 }
		 ```

		 - Parameters:
			- sheet: The sheet item to be presented.
			- animated: A flag indicating whether the presentation should be animated. Default is true.
			- action: A closure to be executed after presenting the sheet.
	*/
	public func presentSheet(
		_ sheet: Item,
		animated: Bool = true,
		action: Completion? = nil
	) -> Void {
		lastPresentationStyle = sheet.presentationStyle
		
		let runAction = { [weak self] () -> Void in
			self?.items.append(sheet)
			self?.removeAllNilItems()
			action?()
		}
		
		if animated {
			items.append(nil)
			return makeDelay(
				animated: animated,
				customTime: 60 / 1000, // 0.6 millisecon
				action: runAction
			)
		}
		
		runAction()
	}
	
	/**
		Removes the last presented sheet asynchronously.

		Example usage:
		```swift
		sheetCoordinator.removeLastSheet(animated: true) {
			// Completion block after removing the last sheet
		}
		```

		- Parameters:
		   - animated: A flag indicating whether the removal should be animated. Default is true.
		   - action: A closure to be executed after removing the last sheet.
	*/
	func removeLastSheet(animated: Bool = true, action: Completion? = nil) -> Void {
		guard !items.isEmpty, !isCleaning else {
			action?()
			return
		}
		removeNilItems(at: totalItems)
		makeDelay(animated: animated) { [weak self] in
			self?.removeAllNilItems()
			action?()
		}
	}
	
	/**
		 Removes a sheet item at the specified index.

		 Example usage:
		 ```swift
		 sheetCoordinator.remove(at: 0)
		 ```

		 - Parameters:
			- index: The index of the sheet item to be removed.
	*/
	func remove(at index: Int) {
		guard totalItems >= index, !isCleaning else { return }
		items.remove(at: index)
	}
	
	/**
		 Removes all sheet items and their corresponding views asynchronously.

		 Example usage:
		 ```swift
		 sheetCoordinator.clean(animated: true) {
			 // Completion block after cleaning up the sheet items
		 }
		 ```

		 - Parameters:
			- animated: A flag indicating whether the cleanup should be animated. Default is true.
			- action: A closure to be executed after cleaning up the sheet items.
	*/
	func clean(animated: Bool = true, action: Completion? = nil) -> Void {
		
		guard !items.isEmpty, !isCleaning else {
			action?()
			return
		}
		isCleaning = true
		removeNilItems(at: 0)
		makeDelay(animated: animated){ [weak self] in
			self?.resetValues()
			action?()
		}
	}
	
	// ---------------------------------------------------------
	// MARK: Private helper funcs
	// ---------------------------------------------------------
	
	/**
		 Removes all nil items from the sheet stack.

		 Example usage:
		 ```swift
		 sheetCoordinator.removeAllNilItems()
		 ```

		 - Note: The `removeAllNilItems` method removes all nil items from the sheet stack.
	*/
	private func removeAllNilItems() {
		items.removeAll(where: { $0 == nil || $0?.view == nil })
	}
	
	/**
		 Removes the nil item at the specified index from the sheet stack.

		 Example usage:
		 ```swift
		 sheetCoordinator.removeNilItems(at: 0)
		 ```

		 - Parameters:
			- index: The index of the nil item to be removed.
	*/
	private func removeNilItems(at index: Int) {
		items[index] = nil
	}
	
	/**
		 Resets the values of the sheet coordinator.

		 Example usage:
		 ```swift
		 sheetCoordinator.resetValues()
		 ```

		 - Note: The `resetValues` method sets the sheet coordinator's properties to their default values.
	*/
	private func resetValues() {
		items = []
		lastPresentationStyle = nil
		isCleaning = false
	}
	
	/**
		 Introduces a delay before executing an action.

		 Example usage:
		 ```swift
		 sheetCoordinator.makeDelay(animated: true) {
			 // Action to be executed after the delay
		 }
		 ```

		 - Parameters:
			- animated: A flag indicating whether the delay should be based on animation time. Default is true.
			- customTime: A custom time interval for the delay. If nil, a default time interval is used.
			- action: A closure to be executed after the delay.
	*/
	private func makeDelay(animated: Bool, customTime: Double? = nil, action: @escaping Completion) -> Void {
		var milliSeconds: Double
		if let customTime {
			milliSeconds = customTime
		} else {
			milliSeconds = (animated ? 600 : 300) / 1000
		}
        
		DispatchQueue.main.asyncAfter(
			deadline: .now() + ( milliSeconds )
        ) { action() }
	}
}
