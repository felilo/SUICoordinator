//
//  SUICoordinatorExampleApp.swift
//
//  Copyright (c) Andres F. Lozano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import SwiftUI
import SUICoordinator

/// The main application structure for the SUICoordinator example project.
///
/// This app demonstrates various navigation patterns using the SUICoordinator library,
/// including tab-based navigation (both default and custom tab bars) and deep linking capabilities.
/// It initializes a `CustomTabCoordinator` as its main entry point and showcases how to
/// handle simulated deep links after a short delay on application launch, as well as handling
/// deep links from `onOpenURL` and custom `NotificationCenter` notifications.
@main
struct SUICoordinatorExampleApp: App {
    
    /// The main coordinator for the application, responsible for managing the primary tab-based navigation.
    /// It's an instance of `CustomTabCoordinator` which uses the standard SwiftUI `TabView`.
    var mainCoordinator = DefaultTabCoordinator()
    
    /// The body of the app, defining the main scene.
    /// It sets up a `WindowGroup` containing the view provided by the `mainCoordinator`.
    /// - It includes `onReceive` for handling custom notifications that might trigger deep links.
    /// - It includes `onOpenURL` for handling URL-based deep links.
    /// - An `onAppear` modifier simulates an automatic deep link handling scenario after a 3-second delay
    ///   on application launch, demonstrating programmatic navigation.
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.gray.ignoresSafeArea()
                mainCoordinator.getView()
            }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.PushNotification)) { object in
                    // Assumes `incomingURL` is accessible or passed via notification's object/userInfo
                    // For demonstration, let's assume `object.object` contains the URL string
                    guard let urlString = object.object as? String,
                          let path = DeepLinkPath(rawValue: urlString) else { return }
                    Task {
                        try? await handlePushNotificationDeepLink(path: path, rootCoordinator: mainCoordinator)
                    }
                }
                .onOpenURL { incomingURL in
                    guard let host = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true)?.host,
                          let path = DeepLinkPath(rawValue: host)
                    else { return }
                    
                    Task { @MainActor in
                        try? await handlePushNotificationDeepLink(path: path, rootCoordinator: mainCoordinator)
                    }
                }
        }
    }
    
    /// Defines possible deep link paths for the application.
    /// These raw string values would typically match URL schemes or notification payloads.
    /// - `home`: Represents a path to a home-like view, potentially within a tab, to present a detents sheet.
    /// - `tabCoordinator`: Represents a path to present a `CustomTabCoordinator` modally.
    enum DeepLinkPath: String {
        case home = "home" // Example: "yourapp://home" or a notification payload "home"
        case tabCoordinator = "tabs-coordinator" // Example: "coordinatorApp://tabs-coordinator"
    }
    
    
    /// Handles deep link navigation based on the provided path.
    ///
    /// This function demonstrates how to programmatically navigate to specific parts of the app
    /// by interacting with the coordinator hierarchy. It's designed to be called from
    /// `onOpenURL`, `onReceive` (for notifications), or other app events.
    ///
    /// - Parameters:
    ///   - path: The `DeepLinkPath` indicating the destination within the app.
    ///   - rootCoordinator: The root `AnyCoordinatorType` instance of the application (e.g., `mainCoordinator`),
    ///     used as a starting point to traverse and manipulate the coordinator tree.
    /// - Throws: Can throw errors from coordinator operations, such as `topCoordinator()` or `getCoordinatorSelected()`,
    ///           if the navigation path is invalid or a coordinator is not in the expected state.
    @MainActor func handlePushNotificationDeepLink(
        path: DeepLinkPath,
        rootCoordinator: AnyCoordinatorType
    ) async throws {
        switch path {
        case .tabCoordinator:
            /// Deep-link intent:
            /// Present the detents sheet that belongs to the `HomeCoordinator`
            /// ‑-but only if that coordinator is the one *currently visible* to the user.
            ///
            /// How it works:
            /// `getCoordinatorPresented()` walks the hierarchy to return
            ///    • the “top-most” coordinator of any modal stack, **or**
            ///    • the coordinator that controls the *selected* tab when inside a tab container.
            ///    In short, it yields the coordinator the user is actively interacting with.
            /// When the cast succeeds we call `presentDetents()` which
            ///    brings up the sheet configured inside `HomeCoordinator`.
            
            if let coordinator = try rootCoordinator.getCoordinatorPresented() as? HomeCoordinator {
                await coordinator.presentDetents()
            } else {
                let homeCoordinator = HomeCoordinator()
                try await homeCoordinator.forcePresentation(rootCoordinator: rootCoordinator)
                await homeCoordinator.presentDetents()
            }
        case .home:
            // This case demonstrates presenting a different Coordinator modally (HomeCoordinator in this example).
            // It creates a new `HomeCoordinator` instance and uses `forcePresentation`
            // to display it as a sheet over the current context, managed by the `mainCoordinator`.
            let coordinator = HomeCoordinator()
            try await coordinator.forcePresentation(
                presentationStyle: .sheet,
                rootCoordinator: mainCoordinator
            )
        }
    }
}

extension Notification.Name {
    static let PushNotification = Notification.Name("PushNotification")
}
