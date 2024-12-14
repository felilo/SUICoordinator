//
//  AppDelegate.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SwiftUI
import SUICoordinator

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var mainCoodinator: HomeCoordinator?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        mainCoodinator = HomeCoordinator()
        
        // Simulate the receipt of a notification or external trigger to present the some coordinator
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            Task { [weak self] in
                // Create and present the CustomTabbarCoordinator in a sheet presentation style
                let coordinator = CustomTabbarCoordinator()
                try? await coordinator.forcePresentation(
                    presentationStyle: .sheet,
                    mainCoordinator: self?.mainCoodinator
                )
            }
        }
        
        return true
    }
}
