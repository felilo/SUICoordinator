//
//  FirstViewModel.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import Foundation

class SheetViewModel: ObservableObject {
    
    let coordinator: HomeCoordinator
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }
    
    func navigateToNextView() {
        coordinator.presentFullscreen()
    }
    
    func close() {
        coordinator.close()
    }
}
