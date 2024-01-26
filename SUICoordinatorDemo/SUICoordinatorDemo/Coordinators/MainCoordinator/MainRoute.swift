//
//  MainCoordinatorRoute.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SUICoordinator
import SwiftUI

enum MainRoute: RouteType {
    
    case splash
    
    // ---------------------------------------------------------
    // MARK: RouteNavigation
    // ---------------------------------------------------------
    
    public var presentationStyle: TransitionPresentationStyle {
        switch self {
            case .splash:
                return .push
        }
    }
    
    @ViewBuilder
    public var view: any View {
        switch self {
            case .splash:
                SplashView()
        }
    }
}
