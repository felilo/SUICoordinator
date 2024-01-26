//
//  SheetItem.swift
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
