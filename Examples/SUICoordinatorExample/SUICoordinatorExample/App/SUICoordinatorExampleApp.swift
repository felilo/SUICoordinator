//
//  SUICoordinatorExampleApp.swift
//  SUICoordinatorExample
//
//  Created by Andres Lozano on 26/01/24.
//

import SwiftUI

@available(iOS 16.0, *)
@main
struct SUICoordinatorExampleApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            if let view = appDelegate.mainCoodinator?.view {
                AnyView(view)
            }
        }
    }
}
