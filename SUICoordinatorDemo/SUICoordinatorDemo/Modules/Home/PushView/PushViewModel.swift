//
//  FirstViewModel.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import Foundation

class PushViewModel: ObservableObject {
    
    unowned var coordinator: HomeCoordinator
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }
    
    func navigateToNextView() {
        coordinator.presentSheet()
    }
    
    func close() {
        coordinator.close()
    }
}
