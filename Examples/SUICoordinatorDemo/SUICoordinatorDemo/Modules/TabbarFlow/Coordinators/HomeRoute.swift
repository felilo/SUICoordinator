//
//  HomeRoute.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import Foundation
import SUICoordinator

enum HomeRoute: RouteType {
    
    case firstView(viewModel: FirstViewModel)
    case secondView(viewModel: SecondViewModel)
    case thirdView(viewModel: ThirdViewModel)
    case fourthView(viewModel: FourthViewModel)
    case actionListView(viewModel: ActionListViewModel)
    
    
    var navigationStyle: TransitionPresentationStyle {
        switch self {
            case .firstView:
                return .push
            case .secondView:
                return .sheet
            case .thirdView:
                return .fullScreenCover
            case .fourthView:
                return .detents([.medium])
            case .actionListView:
                return .push
        }
    }
    
    var view: Body {
        
        switch self {
            case .firstView(let viewModel):
                return FirstView(viewModel: viewModel)
            case .secondView(let viewModel):
                return SecondView(viewModel: viewModel)
            case .thirdView(let viewModel):
                return ThirdView(viewModel: viewModel)
            case .fourthView(let viewModel):
                return FourthView(viewModel: viewModel)
            case .actionListView(let viewModel):
                return ActionListView(viewModel: viewModel)
        }
    }
}
