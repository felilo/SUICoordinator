//
//  FirstViewModel.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import Foundation

class FullscreenViewModel: ObservableObject {
    
    let coordinator: HomeCoordinator
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }
    
    func navigateToNextView() {
        coordinator.presentDetents()
    }
    
    func close() {
        coordinator.close()
    }
}
