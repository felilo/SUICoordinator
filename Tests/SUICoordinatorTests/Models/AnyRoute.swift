//
//  File.swift
//  
//
//  Created by Andres Lozano on 18/01/24.
//


import SwiftUI
@testable import SUICoordinator


enum AnyEnumRoute: RouteType {
    
    case pushStep
    case pushStep2
    case pushStep3
    case fullScreenStep
    case sheetStep
    case detentsStep
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
            case .pushStep, .pushStep2, .pushStep3: return .push
            case .fullScreenStep: return .fullScreenCover
            case .sheetStep: return .sheet
            case .detentsStep: return .detents([.medium])
        }
    }
    
    var view: Body {
        switch self {
            case .pushStep:
                return Text("pushStep")
            case .pushStep2:
                return Text("pushStep2")
            case .pushStep3:
                return Text("pushStep3")
            case .fullScreenStep:
                return Text("fullScreenStep")
            case .sheetStep:
                return Text("sheetStep")
            case .detentsStep:
                return Text("detentsStep")
        }
    }
}


struct AnyStructRoute: RouteType {
    
    var _presentationStyle: TransitionPresentationStyle
    var presentationStyle: TransitionPresentationStyle { _presentationStyle }
    var view: Body { Text("AnyStructRoute") }
    
    init(presentationStyle: TransitionPresentationStyle) {
        _presentationStyle = presentationStyle
    }
}
