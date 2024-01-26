//
//  TabbarCoordinatorType.swift
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
import Combine

/**
 Protocol defining the requirements for a tab bar coordinator in the Coordinator pattern.

 TabbarCoordinatorType represents coordinators that are associated with a tab bar interface within an application. It facilitates the coordination and management of multiple pages or views accessible through a tab bar.

 Conforming types must provide an associated type `PAGE`, which represents the type of pages or views managed by the tab bar coordinator.
 */
public protocol TabbarCoordinatorType {
	
	// ---------------------------------------------------------
	// MARK: typealias
	// ---------------------------------------------------------
	
	/// The associated type representing the type of pages or views managed by the tab
	associatedtype PAGE
	
	// ---------------------------------------------------------
	// MARK: Properties
	// ---------------------------------------------------------
	
	/// The current page or view associated with the tab bar coordinator.
	var currentPage: PAGE { get set }
	
	var setBadge: PassthroughSubject<(String?, PAGE), Never> { get set }
	
	// ---------------------------------------------------------
	// MARK: Funcs
	// ---------------------------------------------------------
	
	/**
	Retrieves the selected coordinator associated with the current page.

	 - Throws: An error if the selected coordinator cannot be retrieved.
	 - Returns: The type-erased coordinator associated with the current page.
	*/
	func getCoordinatorSelected() throws -> (any CoordinatorType)
}

public typealias TabbarCoordinatable = CoordinatorType & TabbarCoordinatorType
