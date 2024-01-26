//
//  HomeCoordinator.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SUICoordinator
import Foundation

class HomeCoordinator: Coordinator<HomeRoute> {
    
    override func start(animated: Bool = true, completion: Completion? = nil) {
        let viewModel = ActionListViewModel(coordinator: self)
        startFlow(route: .actionListView(viewModel: viewModel))
    }
    
    func navigateToFirstView() {
        let viewModel = FirstViewModel(coordinator: self)
        router.navigate(to: .firstView(viewModel: viewModel))
    }
    
    func presentSheet() {
        let viewModel = SecondViewModel(coordinator: self)
        router.navigate(to: .secondView(viewModel: viewModel))
    }
    
    func presentFullscreen() {
        let viewModel = ThirdViewModel(coordinator: self)
        router.navigate(to: .thirdView(viewModel: viewModel))
    }
    
    func presentDetents() {
        let viewModel = FourthViewModel(coordinator: self)
        router.navigate(to: .fourthView(viewModel: viewModel))
    }
    
    func presentDefaultTabbarCoordinator() {
        let coordinator = DefaultTabbar()
        navigate(to: coordinator, transitionStyle: .sheet)
    }
    
    func presentCustomTabbarCoordinator() {
        let coordinator = CustomTabbarCoordinator()
        navigate(to: coordinator, transitionStyle: .sheet)
    }
    
    func close() {
        router.close(completion: nil)
    }
    
}

