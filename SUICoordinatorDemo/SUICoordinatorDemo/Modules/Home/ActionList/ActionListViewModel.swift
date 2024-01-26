//
//  FirstViewModel.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import Foundation

class ActionListViewModel: ObservableObject {
    
    let coordinator: HomeCoordinator
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }
    
    func navigateToFirstView() {
        coordinator.navigateToFirstView()
    }
    
    func presentSheet() {
        coordinator.presentSheet()
    }
    
    func presentFullscreen() {
        coordinator.presentFullscreen()
    }
    
    func presentDetents() {
        coordinator.presentDetents()
    }
    
    func presentTabbarCoordinator() {
        coordinator.presentTabbarCoordinator()
    }
    
    func finsh() {
        coordinator.finsh()
    }
    
    func showFinishButton() -> Bool {
        !(coordinator.parent is MainCoordinator)
    }
}
