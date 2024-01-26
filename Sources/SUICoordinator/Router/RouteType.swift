//
//  Route.swift
//  Navigation
//
//  Created by Andres Lozano on 30/11/23.
//

import SwiftUI

/**
 Protocol defining the requirements for a route in the Coordinator pattern.

 Routes represent the different views or navigation actions that can be handled by a coordinator or router within an application.

 Conforming types must provide a type alias `Body`, which represents the body of the route and conforms to the `View` protocol.
*/
public protocol RouteType: SCHashable {
	
	// ---------------------------------------------------------
	// MARK: typealias
	// ---------------------------------------------------------
	
	/// A type alias representing the body of the route, conforming to the View protocol.
	typealias Body = (any View)
	
	// ---------------------------------------------------------
	// MARK: Properties
	// ---------------------------------------------------------
	
	/// The transition style for presenting the view.
	var presentationStyle: TransitionPresentationStyle { get }
	
	/// The body of the route, conforming to the View protocol.
	@ViewBuilder var view: Body { get }
}
