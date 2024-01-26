//
//  NavigatorBase.swift
//  CRNavigation
//
//  Created by Andres Lozano on 4/12/23.
//

import Foundation
import SwiftUI

public struct RouteBase: RouteType {
	
	// ---------------------------------------------------------
	// MARK: Properties
	// ---------------------------------------------------------
	
	private let _presentationStyle: TransitionPresentationStyle
	public var content: any View
	
	// ---------------------------------------------------------
	// MARK: Constructor
	// ---------------------------------------------------------
	
	public init(
        presentationStyle: TransitionPresentationStyle,
		content: (any View)
	) {
		self.content = content
		self._presentationStyle = presentationStyle
	}
	
	// ---------------------------------------------------------
	// MARK: RouteNavigation
	// ---------------------------------------------------------
	
	public var presentationStyle: TransitionPresentationStyle {
		_presentationStyle
	}
	
	@ViewBuilder
	public var view: any View {
		content
	}
}
