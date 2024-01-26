//
//  Coordinator.swift
//  Navigation
//
//  Created by Andres Lozano on 30/11/23.
//

import Foundation
import SwiftUI

/**
 Protocol defining the requirements for a coordinator following the Coordinator pattern.
 
 Coordinators are responsible for coordinating the flow and navigation within an application. They manage the navigation hierarchy and facilitate communication between different parts of the app.
 
 Conforming types must provide an associated type `Route`, which represents the possible routes or navigation actions that the coordinator can handle.
 
 Additionally, conforming types must define a type alias `Completion` representing a closure that takes no parameters and returns void.
 */

public protocol CoordinatorType: SCHashable, AnyObject {
	
	// ---------------------------------------------------------
	// MARK: typealias
	// ---------------------------------------------------------
	
	/// A closure type representing a completion handler with no parameters and void return.
	typealias Completion = (() -> Void)
	
	/// A type-erased coordinator type.
	typealias TCoordinatorType = (any CoordinatorType)
	
	// ---------------------------------------------------------
	// MARK: associatedtype
	// ---------------------------------------------------------
	
	/// The associated type representing the possible routes or navigation actions that the coordinator can handle.
	associatedtype Route: RouteType
	
	// ---------------------------------------------------------
	// MARK: Properties
	// ---------------------------------------------------------
	
	/// A unique identifier for the coordinator.
	var uuid: String { get set }
	
	/// An optional identifier for tagging purposes.
	var tagId: String? { get set }
	
	/// The parent coordinator, allowing for hierarchical coordination.
	var parent: TCoordinatorType! { get set }
	
	/// The array of child coordinators associated with the current coordinator.
	var children: [TCoordinatorType] { get set }
	
	/// The router responsible for handling the navigation stack.
	var router: Router<Route> { get set }
	
	/// The associated view for the coordinator, conforming to the View protocol.
	var view: (any View) { get }
	
	// ---------------------------------------------------------
	// MARK: Helpers func
	// ---------------------------------------------------------
	
	/**
	 Starts the coordinator, initiating its functionality.
	 
	 Parameter animated: A flag indicating whether the start action should be animated.
	 */
    func start(animated: Bool, completion: Completion?) -> Void
}
