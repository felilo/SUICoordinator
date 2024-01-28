//
//  CoordinatorType.swift
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
import SwiftUI

/**
 Protocol defining the requirements for a coordinator following the Coordinator pattern.
 
 Coordinators are responsible for coordinating the flow and navigation within an application. They manage the navigation hierarchy and facilitate communication between different parts of the app.
 
 Conforming types must provide an associated type `Route`, which represents the possible routes or navigation actions that the coordinator can handle.
 */

public protocol CoordinatorType: SCHashable, AnyObject {
	
	// ---------------------------------------------------------
	// MARK: typealias
	// ---------------------------------------------------------
	
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
    func start(animated: Bool) async -> Void
}
