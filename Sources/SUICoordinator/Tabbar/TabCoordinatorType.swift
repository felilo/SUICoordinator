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
import Combine

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
/// class MyTabCoordinator: TabCoordinatorType {
///     // Implementation details...
/// }
/// ```
@MainActor
public protocol TabCoordinatorType: ObservableObject {
    
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
    
    /// A publisher for setting badge values on specific pages.
    ///
    /// Send badge updates through this subject using a tuple containing the badge value
    /// (or `nil` to remove the badge) and the target page. The tab interface will
    /// automatically update to reflect the new badge state.
    ///
    /// Example usage:
    /// ```swift
    /// setBadge.send(("5", myPage)) // Set badge to "5"
    /// setBadge.send((nil, myPage)) // Remove badge
    /// ```
    var badge: PassthroughSubject<(String?, Page), Never> { get }
    
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
    var viewContainer: (TabCoordinator<Page>) -> (Page.View) { get set }
    
    
    // ---------------------------------------------------------
    // MARK: Functions
    // ---------------------------------------------------------
    
    /// Retrieves the coordinator at a specified position in the tab coordinator.
    ///
    /// This method allows you to access child coordinators by their position in the tab bar,
    /// which is useful for programmatic navigation or coordinator interaction.
    ///
    /// - Parameter position: The zero-based index of the coordinator to retrieve.
    /// - Returns: The coordinator at the specified position, or `nil` if no coordinator
    ///           exists at that index or the position is out of bounds.
    ///
    /// ## Example Usage
    /// ```swift
    /// if let firstCoordinator = tabCoordinator.getCoordinator(with: 0) {
    ///     // Interact with the first tab's coordinator
    /// }
    /// ```
    func getCoordinator(with page: Page) -> AnyCoordinatorType?
    
    /// Retrieves the currently selected coordinator within the tab coordinator.
    ///
    /// This method returns the child coordinator that corresponds to the currently
    /// active tab, allowing you to interact with the active tab's navigation flow.
    ///
    /// - Returns: The coordinator that corresponds to the currently selected tab.
    /// - Throws: An error if the selected coordinator cannot be determined or found.
    ///
    /// ## Example Usage
    /// ```swift
    /// do {
    ///     let activeCoordinator = try tabCoordinator.getCoordinatorSelected()
    ///     // Work with the active coordinator
    /// } catch {
    ///     print("Failed to get selected coordinator: \(error)")
    /// }
    /// ```
    func getCoordinatorSelected() throws -> (any CoordinatorType)
    
    /// Performs cleanup operations for the coordinator.
    ///
    /// This method should be called to release resources, clear state, and properly
    /// dispose of child coordinators when the tab coordinator is no longer needed.
    /// It's essential to call this method to prevent memory leaks.
    ///
    /// The cleanup process typically includes:
    /// - Releasing child coordinators
    /// - Clearing cached data
    /// - Canceling active subscriptions
    /// - Resetting internal state
    ///
    /// ## Example Usage
    /// ```swift
    /// await tabCoordinator.clean()
    /// ```
    @MainActor func clean() async
    
    func setBadge(for page: Page, with value: String?)
}

/// A type alias representing a coordinator that conforms to both `CoordinatorType` and `TabCoordinatorType`.
///
/// This convenience type alias represents coordinators that can function both as regular
/// coordinators and as tab coordinators, providing the full functionality of both protocols.
public typealias TabCoordinatable = CoordinatorType & TabCoordinatorType
