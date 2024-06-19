//
//  NavigatorBase.swift
//  CRNavigation
//
//  Created by Andres Lozano on 4/12/23.
//

import Foundation
import SwiftUI

/// A struct representing a default route with a specified presentation style and content view.
public struct DefaultRoute: RouteType {
    
    // ---------------------------------------------------------
    // MARK: - Properties
    // ---------------------------------------------------------
    
    /// The presentation style for the route transition.
    private let _presentationStyle: TransitionPresentationStyle
    
    /// The content view for the route.
    public var content: any View
    
    // ---------------------------------------------------------
    // MARK: - Constructor
    // ---------------------------------------------------------
    
    /// Initializes a new instance of `DefaultRoute`.
    ///
    /// - Parameters:
    ///   - presentationStyle: The presentation style for the route transition.
    ///   - content: The content view for the route.
    public init(
        presentationStyle: TransitionPresentationStyle,
        content: (any View)
    ) {
        self.content = content
        self._presentationStyle = presentationStyle
    }
    
    // ---------------------------------------------------------
    // MARK: - RouteNavigation
    // ---------------------------------------------------------
    
    /// The presentation style for the route transition.
    public var presentationStyle: TransitionPresentationStyle {
        _presentationStyle
    }
    
    /// The view to be presented for the route.
    @ViewBuilder
    public var view: any View {
        content
    }
}
