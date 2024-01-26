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
        let viewModel = PushViewModel(coordinator: self)
        router.navigate(to: .push(viewModel: viewModel))
    }
    
    func presentSheet() {
        let viewModel = SheetViewModel(coordinator: self)
        router.navigate(to: .sheet(viewModel: viewModel))
    }
    
    func presentFullscreen() {
        let viewModel = FullscreenViewModel(coordinator: self)
        router.navigate(to: .fullscreen(viewModel: viewModel))
    }
    
    func presentDetents() {
        let viewModel = DetentsViewModel(coordinator: self)
        router.navigate(to: .detents(viewModel: viewModel))
    }
    
    func presentTabbarCoordinator() {
        let coordinator = TabbarFlowCoordinator()
        navigate(to: coordinator, presentationStyle: .sheet)
    }
    
    func close() {
        router.close(completion: nil)
    }
    
    func finsh() {
        finishFlow(animated: true, completion: nil)
    }
}
