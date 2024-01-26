//
//  AppDelegate.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SwiftUI
import SUICoordinator

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var mainCoodinator: (any CoordinatorType)?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        mainCoodinator = MainCoordinator()
        return true
    }
}
