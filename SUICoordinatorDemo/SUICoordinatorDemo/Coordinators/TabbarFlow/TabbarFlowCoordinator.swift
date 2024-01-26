//
//  TabbarFlowCoordinator.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import Foundation
import SUICoordinator

class TabbarFlowCoordinator: Coordinator<RouteBase> {
    
    override func start(animated: Bool = true, completion: Completion? = nil) {
        let viewModel = TabbarActionListViewModel(coordinator: self)
        
        let route = RouteBase(
            presentationStyle: .push,
            content: TabbarActionListView(viewModel: viewModel)
        )
        
        startFlow(route: route )
    }
    
    func presentDefaultTabbarCoordinator() {
        let coordinator = DefaultTabbarCoordinator()
        navigate(to: coordinator, presentationStyle: .fullScreenCover)
    }
    
    func presentCustomTabbarCoordinator() {
        let coordinator = CustomTabbarCoordinator()
        navigate(to: coordinator, presentationStyle: .sheet)
    }
    
    func close() {
        router.close(completion: nil)
    }
    
    func finish() {
        finishFlow(animated: true, completion: nil)
    }
}
