//
//  MainCoordinator.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SUICoordinator
import Foundation

class MainCoordinator: Coordinator<MainRoute> {
    
    override init() {
        super.init()
        startFlow(route: .splash)
    }
    
    override func start(animated: Bool = true, completion sucompletion: Completion? = nil) {
        let coordinator = HomeCoordinator()
        navigate(to: coordinator, presentationStyle: .fullScreenCover)
    }
}
