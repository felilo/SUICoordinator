//
//  SheetCoordinatorType.swift
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

import SwiftUI

/**
 Protocol defining the requirements for a sheet coordinator in the Coordinator pattern.
 
 SheetCoordinatorType represents coordinators responsible for managing the presentation and removal of sheet views within an application. It facilitates the coordination of sheet presentations and provides methods for managing the sheet stack.
 
 Conforming types must provide a type alias `Item`, which represents the sheet item containing a view conforming to the `View` protocol.
 */
public protocol SheetCoordinatorType: ObservableObject {
	
	// ---------------------------------------------------------
	// MARK: typealias
	// ---------------------------------------------------------
	
	/// A type alias representing the sheet item containing a view conforming to the
	typealias Item = SheetItem<(any View)>
	
	// ---------------------------------------------------------
	// MARK: Properties
	// ---------------------------------------------------------
	
	/// The stack of sheet items managed by the coordinator.
	var items: [Item?] { get set }
	/// The presentation style of the last presented sheet.
	var lastPresentationStyle: TransitionPresentationStyle? { get set }
	/// The total number of sheet items in the stack.
	var totalItems: Int { get }
	
	// ---------------------------------------------------------
	// MARK: Funcs
	// ---------------------------------------------------------
	
	/**
	 Presents a sheet with the specified item asynchronously.
		- Parameters:
			- sheet: The sheet item to be presented.
		- Returns: A task representing the asynchronous presentation.
	 */
	func presentSheet(_ sheet: Item) async -> Void
	
	/**
	 Removes the last presented sheet asynchronously.
		- Parameters:
			- animated: A flag indicating whether the removal action should be animated.
		- Returns: A task representing the asynchronous removal.
	 */
	func removeLastSheet(animated: Bool) async -> Void
	
	/**
	 Removes a sheet item at the specified index.
		- Parameters:
			- index: The index of the sheet item to be removed.
	 */
	func remove(at index: Int) -> Void
	
	/**
	 Removes all sheet items and their corresponding views asynchronously.
	 
		- Parameters:
			- animated: A flag indicating whether the removal action should be animated.
		- Returns: A task representing the asynchronous removal.
	 */
	func clean(animated: Bool) async -> Void
}
