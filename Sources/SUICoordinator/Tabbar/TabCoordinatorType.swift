//
//  TabCoordinatorType.swift
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

/// A protocol defining the interface for managing and coordinating tab-based navigation.
///
/// Types conforming to `TabCoordinatorType` provide the core functionality for tab-based
/// navigation including page management, selection handling, badge updates, and coordinator
/// retrieval. This protocol works in conjunction with `CoordinatorType` to provide a complete
/// tab navigation solution.
///
/// The protocol supports:
/// - Dynamic page management with add/remove capabilities
/// - Badge notifications for individual tabs
/// - Custom view containers for tab interface customization
/// - Coordination between tabs and their associated child coordinators
///
/// ## Usage
/// Implement this protocol to create custom tab coordinators, or use the provided
/// `TabCoordinator` class which implements this protocol.
///
/// ```swift
/// class MyTabCoordinator: TabCoordinator<MyTabPage> {
///     // Implementation details...
/// }
/// ```
@available(iOS 17.0, *)
@MainActor
public protocol TabCoordinatorType: Observable, AnyObject {

    // ---------------------------------------------------------
    // MARK: Associated Type
    // ---------------------------------------------------------

    /// The associated type representing the page used by the tab coordinator.
    ///
    /// This must conform to the `TabPage` protocol to ensure the page has the necessary
    /// properties and behavior for tab navigation, including title, icon, position, and
    /// coordinator creation methods.
    associatedtype Page: TabPage

    /// A typealias representing a badge item.
    ///
    /// A badge item is a tuple containing an optional `value` (typically a string representing
    /// a notification count or status) and the associated `page` to which the badge belongs.
    /// The value can be `nil` to indicate no badge should be displayed.
    typealias BadgeItem = (value: String?, page: Page)

    /// A typealias representing the data source page type.
    ///
    /// This provides a convenient reference to the data source associated with the page type,
    /// which contains the visual representation and configuration data for tabs.
    typealias DataSourcePage = Page.DataSource


    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------

    /// The currently selected page in the tab coordinator.
    ///
    /// This property tracks the active tab and should be updated when the user switches tabs.
    /// Changes to this property should trigger UI updates in the tab interface.
    var currentPage: Page { get set }

    /// An async stream that emits badge updates for specific pages.
    ///
    /// Observe this stream to receive badge value changes. Each emitted value is a tuple
    /// containing the badge string (or `nil` to remove the badge) and the target page.
    ///
    /// Example usage:
    /// ```swift
    /// for await (value, page) in coordinator.badges {
    ///     // Update badge for page
    /// }
    /// ```
    var badges: AsyncStream<(String?, Page)> { get }

    /// An array containing all pages managed by the tab coordinator.
    ///
    /// This array represents the complete list of available tabs. Changes to this array
    /// should trigger updates in the tab interface to add, remove, or reorder tabs.
    var pages: [Page] { get set }

    /// A closure that provides the custom view container for the tab interface.
    ///
    /// This closure receives the `TabCoordinator` instance and returns a custom view
    /// that implements the tab interface. If not provided, the coordinator will use
    /// the default `TabViewCoordinator`.
    ///
    /// Use this to completely customize the appearance and behavior of your tab interface:
    /// ```swift
    /// viewContainer = { coordinator in
    ///     MyCustomTabView(coordinator: coordinator)
    /// }
    /// ```
    var viewContainer: @MainActor @Sendable (TabCoordinator<Page>) -> (Page.View) { get }


    // ---------------------------------------------------------
    // MARK: Functions
    // ---------------------------------------------------------

    /// Retrieves the coordinator associated with a specific page.
    ///
    /// - Parameter page: The page whose coordinator should be retrieved.
    /// - Returns: The coordinator for the given page, or `nil` if none exists.
    func getCoordinator(with page: Page) -> AnyCoordinatorType?

    /// Retrieves the currently selected coordinator within the tab coordinator.
    ///
    /// This method returns the child coordinator that corresponds to the currently
    /// active tab, allowing you to interact with the active tab's navigation flow.
    ///
    /// - Returns: The coordinator that corresponds to the currently selected tab.
    /// - Throws: An error if the selected coordinator cannot be determined or found.
    func getCoordinatorSelected() throws -> (any CoordinatorType)

    /// Performs cleanup operations for the coordinator.
    ///
    /// Call this method to release resources, clear state, and properly dispose of child
    /// coordinators when the tab coordinator is no longer needed.
    func clean() async

    /// Sets a badge value on a specific page.
    ///
    /// - Parameters:
    ///   - page: The page on which to set the badge.
    ///   - value: The badge string to display, or `nil` to remove the badge.
    func setBadge(for page: Page, with value: String?)
}

/// A type alias representing a coordinator that conforms to both `CoordinatorType` and `TabCoordinatorType`.
///
/// This convenience type alias represents coordinators that can function both as regular
/// coordinators and as tab coordinators, providing the full functionality of both protocols.
@available(iOS 17.0, *)
public typealias TabCoordinatable = CoordinatorType & TabCoordinatorType
