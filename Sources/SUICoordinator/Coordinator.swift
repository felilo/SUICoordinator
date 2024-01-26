//
//  Coordinator.swift
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
