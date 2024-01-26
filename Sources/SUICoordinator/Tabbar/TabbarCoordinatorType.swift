//
//  BaseTabbarCoordinator.swift
//  CRNavigation
//
//  Created by Andres Lozano on 11/12/23.
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
