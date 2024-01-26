//
//  FirstViewModel.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import Foundation

class DetentsViewModel: ObservableObject {
    
    let coordinator: HomeCoordinator
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }
    
    func navigateToNextView() {
        coordinator.presentTabbarCoordinator()
    }
    
    func close() {
        coordinator.close()
    }
}
