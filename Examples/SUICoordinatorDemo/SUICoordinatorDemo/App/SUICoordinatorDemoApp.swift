//
//  SUICoordinatorDemoApp.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SwiftUI

@main
struct SUICoordinatorDemoApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            if let view = appDelegate.mainCoodinator?.view {
                AnyView(view)
            }
        }
    }
}
