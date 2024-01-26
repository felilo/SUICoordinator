//
//  Coordinator.swift
//  Navigation
//
//  Created by Andres Lozano on 30/11/23.
//

import Foundation
import Combine
import SwiftUI

/**
 An open class serving as a base for coordinators conforming to the `CoordinatorType` protocol.

 The `Coordinator` class provides common functionality for managing the navigation stack using a `NavigationRouter`. It includes default implementations for initializing, starting, and forcing the presentation of a coordinator.

 - Important: Subclasses should override methods and properties as needed.

 Example usage:
 ```swift
 // Create a custom coordinator by subclassing `Coordinator`.
 class MyCoordinator: Coordinator<MyRoute> {
	 // Override methods and properties as needed.
	 override func start(animated: Bool = true) {
		 // Custom implementation for starting the coordinator.
	 }
 }
SeeAlso: CoordinatorType, ObservableObject
*/
open class Coordinator<Route: RouteType>: ObservableObject, CoordinatorType {
	
	// --------------------------------------------------------------------
	// MARK: Wrapper properties
	// --------------------------------------------------------------------
	
	/// The router responsible for handling the navigation stack.
	@Published public var router: Router<Route>
	
	// --------------------------------------------------------------------
	// MARK: Properties
	// --------------------------------------------------------------------
	
	/// A unique identifier for the coordinator.
	public var uuid: String
	/// The parent coordinator, allowing for hierarchical coordination.
	public var parent: (any CoordinatorType)!
	/// The array of child coordinators associated with the current coordinator.
	public var children: [(any CoordinatorType)] = []
	/// An optional identifier for tagging purposes.
	public var tagId: String?
	
	// --------------------------------------------------------------------
	// MARK: Constructor
	// --------------------------------------------------------------------

	/**
	Initializes a new instance of the coordinator with an optional parent coordinator.

	Parameters:
	parent: An optional parent coordinator. Default is nil.
	
	*/
	public init() {
		self.router = .init()
		self.uuid = "\(NSStringFromClass(type(of: self))) - \(UUID().uuidString)"
		self.router.coordinator = self
	}
	
	// --------------------------------------------------------------------
	// MARK: Computed vars
	// --------------------------------------------------------------------
	
	/// The associated view for the coordinator, conforming to the View protocol.
	public var view: any View {
		CoordinatorView(
			viewModel: self,
			onClean: { [weak self] in self?.clean() },
			onSetTag: { [weak self] tag in self?.tagId = tag }
		)
	}
	
	// --------------------------------------------------------------------
	// MARK: Helper funcs
	// --------------------------------------------------------------------
	
	/**
	Starts the coordinator.

	- Parameters:
		- animated: A flag indicating whether the start should be animated. Default is true.
	- Important: Subclasses should override this method with their own custom implementation.
	*/
    open func start(animated: Bool = true, completion: (() -> Void)? = nil) {
		fatalError("This method must be overwritten")
	}
	
	/**
	Forces the presentation of the coordinator.

	- Parameters:
		- animated: A flag indicating whether the presentation should be animated. Default is true.
		- transitionStyle: The transition style for the presentation. Default is .sheet.
		- mainCoordinator: The main coordinator to be used. Default is nil.
	- Throws: An error if the presentation cannot be forced.
	 SeeAlso: TransitionPresentationStyle
	*/
	open func forcePresentation(
		animated: Bool = true,
        presentationStyle: TransitionPresentationStyle = .sheet,
		mainCoordinator: (any CoordinatorType)? = nil,
        completion: Completion? = nil
	) throws {
        let topCoordinator = try mainCoordinator?.topCoordinator()
		topCoordinator?.navigate(to: self, presentationStyle: presentationStyle, completion: completion)
	}
	
	/**
	Cleans up resources associated with the coordinator.

	Important: Subclasses should override this method with their own custom implementation.
	*/
	private func clean() {
		finish(animated: false, withDissmis: false, completion: nil)
	}
}
