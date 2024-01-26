//
//  TabbarRouterNavigation.swift
//  CRNavigation
//
//  Created by Andres Lozano on 11/12/23.
//

import Foundation

public protocol TabbarNavigationRouter {
	
	// ---------------------------------------------------------
	// MARK: Funcs
	// ---------------------------------------------------------
	
	/**
	Retrieves a coordinator associated with the page.

	Returns: The coordinator associated with the page.
	*/
	func coordinator() -> (any CoordinatorType)
}
