//
//  SheetItem.swift
//  CRNavigation
//
//  Created by Andres Lozano on 15/12/23.
//

import Foundation

/**
 A class representing a sheet item in the Coordinator pattern.

 SheetItem manages the properties and behavior of a sheet view to be presented within an application. It includes information about the sheet's view, presentation animation, and transition style.

 Example usage:
 ```swift
 let mySheetItem = SheetItem<MyViewType>(view: myView, animated: true, transitionStyle: .sheet)
*/
final public class SheetItem<T>: SCHashable {
	
	// ---------------------------------------------------------
	// MARK: Properties
	// ---------------------------------------------------------
	
	/// The unique identifier of the sheet item.
	public var id: String
	
	/// The view of the sheet item.
	let view: T
	
	/// A flag indicating whether the sheet should be presented with animation./
	let animated: Bool
	
	/// The transition style for presenting the sheet.
	let presentationStyle: TransitionPresentationStyle
	
	// ---------------------------------------------------------
	// MARK: Constructor
	// ---------------------------------------------------------
	
	/**
	 Initializes a new sheet item with the specified properties.

	 Example usage:
	 ```swift
	 let mySheetItem = SheetItem<MyViewType>(view: myView, animated: true, transitionStyle: .sheet)
	 ```

	 - Parameters:
		- view: The view of the sheet item.
		- animated: A flag indicating whether the sheet should be presented with animation.
		- transitionStyle: The transition style for presenting the sheet.
	 */
    init( id: String = UUID().uuidString, view: T, animated: Bool, presentationStyle: TransitionPresentationStyle) {
		self.view = view
		self.animated = animated
		self.presentationStyle = presentationStyle
		self.id = id
	}
	
	
	/**
	 Cleans up the view if it conforms to the `CoordinatorViewType` protocol.

	 Example usage:
	 ```swift
	 mySheetItem.deinit()
	 ```

	 - Note: The `deinit` method is automatically called when the sheet item is deallocated.
	 */
	deinit {
		if let view = view as? CoordinatorViewType {
			view.clean()
		}
	}
}
