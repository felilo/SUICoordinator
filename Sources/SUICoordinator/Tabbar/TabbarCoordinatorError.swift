//
//  TabbarCoordinatorError.swift
//  CRNavigation
//
//  Created by Andres Lozano on 26/12/23.
//

import Foundation

/**
 An enumeration representing errors specific to `TabbarCoordinatorType`.

 The `TabbarCoordinatorError` enum conforms to the `LocalizedError` protocol to provide localized descriptions for each error case.

 - Important: The `coordinatorSelected` case indicates that there is no coordinator selected.

 Example usage:
 ```swift
 // Handle errors thrown by a TabbarCoordinatorType implementation.
 do {
	 try myTabbarCoordinator.getCoordinatorSelected()
 } catch TabbarCoordinatorError.coordinatorSelected {
	 // Handle the case where there is no coordinator selected.
	 print("Error: There is no coordinator selected.")
 }
 */
public enum TabbarCoordinatorError: LocalizedError {
	
	/// Indicates that there is no coordinator selected.
	case coordinatorSelected
	
	// ---------------------------------------------------------------------
	// MARK: LocalizedError
	// ---------------------------------------------------------------------
	
	/// The localized description for the error.
	public var errorDescription: String? {
		switch self {
			case .coordinatorSelected:
				return "There is no coordinator selected"
		}
	}
}
