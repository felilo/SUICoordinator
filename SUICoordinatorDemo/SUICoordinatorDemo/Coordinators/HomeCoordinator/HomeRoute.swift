//
//  HomeRoute.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import Foundation
import SUICoordinator

enum HomeRoute: RouteType {
    
    case push(viewModel: PushViewModel)
    case sheet(viewModel: SheetViewModel)
    case fullscreen(viewModel: FullscreenViewModel)
    case detents(viewModel: DetentsViewModel)
    case actionListView(viewModel: ActionListViewModel)
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
            case .push:
                return .push
            case .sheet:
                return .sheet
            case .fullscreen:
                return .fullScreenCover
            case .detents:
                return .detents([.medium])
            case .actionListView:
                return .push
        }
    }
    
    
    var view: Body {
        switch self {
            case .push(let viewModel):
                return PushView(viewModel: viewModel)
            case .sheet(let viewModel):
                return SheetView(viewModel: viewModel)
            case .fullscreen(let viewModel):
                return FullscreenView(viewModel: viewModel)
            case .detents(let viewModel):
                return DetentsView(viewModel: viewModel)
            case .actionListView(let viewModel):
                return ActionListView(viewModel: viewModel)
        }
    }
}
