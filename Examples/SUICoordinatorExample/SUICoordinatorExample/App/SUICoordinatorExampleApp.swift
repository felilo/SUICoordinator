//
//  SUICoordinatorExampleApp.swift
//  SUICoordinatorExample
//
//  Created by Andres Lozano on 26/01/24.
//

import SwiftUI

@main
struct SUICoordinatorExampleApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            appDelegate.mainCoodinator?.getView()
        }
    }
}
