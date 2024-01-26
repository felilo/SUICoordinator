//
//  FirstViewModel.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import Foundation

class TabbarActionListViewModel: ObservableObject {
    
    let coordinator: TabbarFlowCoordinator
    
    init(coordinator: TabbarFlowCoordinator) {
        self.coordinator = coordinator
    }
    
    func presentDefaultTabbarCoordinator() {
        coordinator.presentDefaultTabbarCoordinator()
    }
    
    func presentCustomTabbarCoordinator() {
        coordinator.presentCustomTabbarCoordinator()
    }
    
    func finsh() {
        coordinator.finish()
    }
}
