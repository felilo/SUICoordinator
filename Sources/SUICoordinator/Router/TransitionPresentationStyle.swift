//
//  TransitionPresentationStyle.swift
//  CRNavigation
//
//  Created by Andres Lozano on 12/12/23.
//

import SwiftUI

/**
 Enum defining the transition styles for presentation in the Coordinator pattern.
 
 TransitionPresentationStyle enumerates the different styles used for transitioning between views or presenting views within an application.
 */
public enum TransitionPresentationStyle: SCEquatable {
	
	/// A push transition style, commonly used in navigation controllers.
	case push
	/// A sheet presentation style, often used for modal or overlay views.
	case sheet
	/// A full-screen cover presentation style.
	case fullScreenCover
	/// A style allowing for presenting views with specific detents.
	case detents(Set<PresentationDetent>)
}
