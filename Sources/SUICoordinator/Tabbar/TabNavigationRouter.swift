//
//  TabNavigationRouter.swift
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
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR THE OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// A protocol representing a type for managing and providing coordinators for tab navigation.
///
/// `TabNavigationRouter` defines the interface for types that can create and provide
/// coordinators for tab-based navigation. This protocol is essential for tab pages
/// that need to manage their own navigation flow through dedicated coordinators.
///
/// Types conforming to this protocol are responsible for creating and returning
/// the appropriate coordinator that will handle the navigation logic for a specific tab.
public protocol TabNavigationRouter: Sendable {
    
    // ---------------------------------------------------------
    // MARK: Functions
    // ---------------------------------------------------------
    
    /// Retrieves a coordinator associated with tab navigation.
    ///
    /// This method is responsible for creating and returning the coordinator that will
    /// manage the navigation flow for this specific tab. Each tab should have its own
    /// coordinator to handle its unique navigation requirements.
    ///
    /// - Returns: The coordinator associated with this tab's navigation flow.
    ///            The coordinator should conform to `CoordinatorType` and be ready to handle
    ///            the navigation logic for this tab.
    ///
    /// - Important: This method is marked with `@MainActor` to ensure it runs on the main thread,
    ///              which is required for coordinator operations that may involve UI updates.
    ///
    /// ## Example Implementation
    /// ```swift
    /// enum MyTabs: TabNavigationRouter {
    ///     case home, profile, settings
    ///
    ///     @MainActor
    ///     func coordinator() -> (any CoordinatorType) {
    ///         switch self {
    ///         case .home:
    ///             return HomeCoordinator()
    ///         case .profile:
    ///             return ProfileCoordinator()
    ///         case .settings:
    ///             return SettingsCoordinator()
    ///         }
    ///     }
    /// }
    /// ```
    @MainActor func coordinator() -> (any CoordinatorType)
}
