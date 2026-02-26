//
//  Coordinator.swift
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

import Foundation
import Combine

/// An open class representing a coordinator in a coordinator-based architecture.
///
/// `Coordinator` is the base implementation of the coordinator pattern, responsible for
/// coordinating navigation flow and managing the presentation of views within an application.
/// It provides a structured approach to navigation that separates navigation logic from view logic.
///
/// ## Key Features
/// - **Navigation Management**: Handles all navigation operations through an integrated router
/// - **Hierarchical Structure**: Supports parent-child coordinator relationships
/// - **Generic Route Support**: Works with any route type that conforms to `RouteType`
/// - **Observable**: Integrates seamlessly with SwiftUI through `ObservableObject`
/// - **Lifecycle Management**: Provides structured initialization and cleanup
///
/// ## Architecture Benefits
/// - **Separation of Concerns**: Navigation logic separated from view logic
/// - **Testability**: Navigation flows can be unit tested independently
/// - **Reusability**: Coordinators can be reused across different parts of the app
/// - **Scalability**: Complex navigation flows are manageable and maintainable
///
/// ## Example Implementation
/// ```swift
/// enum AppRoute: RouteType {
///     case home, profile, settings
///
///     var presentationStyle: TransitionPresentationStyle {
///         switch self {
///         case .home: return .push
///         case .profile: return .push
///         case .settings: return .sheet
///         }
///     }
///
///     @ViewBuilder @MainActor
///     var view: Body {
///         switch self {
///         case .home: HomeView()
///         case .profile: ProfileView()
///         case .settings: SettingsView()
///         }
///     }
/// }
///
/// class AppCoordinator: Coordinator<AppRoute> {
///     override func start(animated: Bool = true) async {
///         await startFlow(route: .home, animated: animated)
///     }
///
///     func showProfile() async {
///         await router.navigate(toRoute: .profile, animated: true)
///     }
///
///     func showSettings() async {
///         await router.present(.settings, animated: true)
///     }
/// }
/// ```
open class Coordinator<Route: RouteType>: ObservableObject, CoordinatorType {
    
    // --------------------------------------------------------------------
    // MARK: Wrapper properties
    // --------------------------------------------------------------------
    
    /// The published router associated with the coordinator.
    ///
    /// This router handles all navigation operations for the coordinator, including
    /// push navigation, modal presentations, and navigation stack management.
    /// Changes to the router state automatically trigger UI updates.
    @Published public var router: Router<Route>
    
    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------
    
    /// The unique identifier for the coordinator.
    ///
    /// This UUID-based identifier uniquely identifies each coordinator instance,
    /// which is essential for proper coordinator hierarchy management and cleanup.
    /// The identifier combines the class name with a UUID for debugging clarity.
    public var uuid: String
    
    /// The parent coordinator associated with the coordinator.
    ///
    /// This property establishes the hierarchical relationship between coordinators.
    /// Child coordinators hold a reference to their parent, enabling proper cleanup
    /// and navigation delegation when needed.
    public var parent: (any CoordinatorType)?
    
    /// The array of children coordinators associated with the coordinator.
    ///
    /// This array maintains all child coordinators that have been started by this coordinator.
    /// It's essential for proper memory management and hierarchical navigation operations.
    /// Child coordinators are automatically cleaned up when the parent is deallocated.
    public var children: [(any CoordinatorType)] = []
    
    /// The tag identifier associated with the coordinator.
    ///
    /// This optional string identifier is used for specific coordinator identification,
    /// particularly useful in tab-based coordinators where each tab needs a unique identifier.
    public var tagId: String?
    
    // --------------------------------------------------------------------
    // MARK: Constructor
    // --------------------------------------------------------------------
    
    /// Initializes a new instance of `Coordinator`.
    ///
    /// Creates a new coordinator with an associated router and generates a unique identifier.
    /// The coordinator is initialized in a clean state, ready to begin its navigation flow.
    ///
    /// ## Initialization Process
    /// 1. Creates a new router instance for navigation operations
    /// 2. Generates a unique identifier combining class name and UUID
    /// 3. Configures the router for non-tab-coordinable behavior by default
    ///
    /// ## Usage Notes
    /// - Subclasses should call `super.init()` if they override the initializer
    /// - The coordinator is not started automatically; call `start()` explicitly
    /// - Router configuration can be modified after initialization if needed
    public init() {
        self.router = .init()
        self.uuid = "\(NSStringFromClass(type(of: self))) - \(UUID().uuidString)"
    }
    
    // --------------------------------------------------------------------
    // MARK: Helper funcs
    // --------------------------------------------------------------------
    
    /// Starts the coordinator.
    ///
    /// This method must be overridden by subclasses to define the coordinator's
    /// initial navigation flow. It's called to begin the coordinator's lifecycle
    /// and establish its initial view state.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the start process.
    ///               Defaults to `true`.
    ///
    /// - Important: Subclasses **must** override this method with their own custom implementation.
    ///              The default implementation throws a fatal error to ensure proper subclassing.
    ///
    /// ## Example Override
    /// ```swift
    /// override func start(animated: Bool = true) async {
    ///     // Set up the initial route
    ///     await startFlow(route: .home, animated: animated)
    ///
    ///     // Perform any additional setup
    ///     setupNotifications()
    ///     loadInitialData()
    /// }
    /// ```
    ///
    /// ## Common Start Patterns
    /// - **Simple Flow**: Start with a single main view
    /// - **Conditional Flow**: Choose initial route based on app state
    /// - **Tab Flow**: Initialize tab-based navigation
    /// - **Onboarding Flow**: Start with authentication or tutorial flows
    open func start() async {
        fatalError("This method must be overwritten")
    }
}
