//
//  PageDataSource.swift
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

/// A protocol representing a data source for a page in tab-based navigation.
///
/// `PageDataSource` provides the essential information needed to display a tab in the tab interface,
/// including its visual representation and its position in the tab bar. This protocol serves as
/// the foundation for creating tab pages with consistent data provision patterns.
///
/// Types conforming to this protocol define how each tab appears to the user and where it should
/// be positioned relative to other tabs. The protocol supports separation of concerns by allowing
/// the visual representation to be handled by a separate data source object.
///
/// ## Key Features
/// - **Position Management**: Defines tab ordering through the `position` property
/// - **Data Source Separation**: Delegates visual representation to associated data source
/// - **Type Safety**: Ensures consistent data handling through associated types
/// - **Flexibility**: Supports custom data source implementations
///
/// ## Usage Example
/// ```swift
/// enum MyTabPage: PageDataSource {
///     case home, profile, settings
///
///     var position: Int {
///         switch self {
///         case .home: return 0
///         case .profile: return 1
///         case .settings: return 2
///         }
///     }
///
///     var dataSource: MyTabDataSource {
///         return MyTabDataSource(page: self)
///     }
/// }
/// ```
public protocol PageDataSource: SCHashable {
    
    // ---------------------------------------------------------
    // MARK: Associated Types
    // ---------------------------------------------------------
    
    /// The associated type representing the data source for the page.
    ///
    /// This type contains the actual data and visual representation logic for the tab page.
    /// It should provide methods and properties for rendering the tab's title, icon, and
    /// other visual elements.
    ///
    /// The data source pattern allows for clean separation between the page identifier
    /// (conforming to PageDataSource) and the visual/behavioral aspects of the tab.
    associatedtype DataSource
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The data source instance associated with this page.
    ///
    /// This property provides access to the visual and behavioral data for the tab page.
    /// The data source typically contains methods for generating the tab's title, icon,
    /// and other UI elements.
    ///
    /// ## Example Implementation
    /// ```swift
    /// var dataSource: TabDataSource {
    ///     return TabDataSource(
    ///         title: "Home",
    ///         icon: Image(systemName: "house"),
    ///         page: self
    ///     )
    /// }
    /// ```
    var dataSource: DataSource { get }
    
    /// A type alias representing a SwiftUI view.
    ///
    /// This is used to ensure type safety when working with SwiftUI views in the context of tab pages.
    /// It provides a consistent interface for view-related operations across the tab system.
    typealias View = (any SwiftUI.View)
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The position of the page in the tab bar.
    ///
    /// This integer value determines the order in which tabs appear in the tab bar interface.
    /// Lower values appear first (leftmost in horizontal layouts, topmost in vertical layouts).
    ///
    /// ## Guidelines
    /// - Position values should be unique across all tabs to ensure proper ordering
    /// - Use sequential integers (0, 1, 2, ...) for predictable tab ordering
    /// - Gaps in numbering are allowed but not recommended for maintainability
    ///
    /// ## Example
    /// ```swift
    /// var position: Int {
    ///     switch self {
    ///     case .home: return 0      // First tab
    ///     case .search: return 1    // Second tab
    ///     case .profile: return 2   // Third tab
    ///     }
    /// }
    /// ```
    ///
    /// - Important: Position values should be unique across all tabs to ensure proper ordering.
    var position: Int { get }
}

/// An extension for `PageDataSource` to provide utility methods for types that are also `CaseIterable`.
///
/// This extension adds convenient methods for working with collections of page data sources,
/// particularly useful when you have an enum that represents all available tabs and need
/// to process them as a sorted collection.
public extension PageDataSource where Self: CaseIterable {
    
    /// Sorts all cases of `PageDataSource` by their position.
    ///
    /// This method provides a convenient way to get all available pages sorted by their
    /// position property, which is useful when setting up the tab interface or when you
    /// need to iterate through tabs in their display order.
    ///
    /// The sorting is performed based on the `position` property of each case, ensuring
    /// that tabs appear in the correct order regardless of their declaration order in
    /// the enum or their raw values.
    ///
    /// - Returns: An array of sorted `PageDataSource` cases ordered by their position values.
    ///
    /// ## Example Usage
    /// ```swift
    /// enum MyTabs: PageDataSource, CaseIterable {
    ///     case home, profile, settings
    ///
    ///     var position: Int {
    ///         switch self {
    ///         case .home: return 0
    ///         case .profile: return 1
    ///         case .settings: return 2
    ///         }
    ///     }
    ///     // ... other properties
    /// }
    ///
    /// let sortedTabs = MyTabs.sortedByPosition() // [.home, .profile, .settings]
    ///
    /// // Use in tab coordinator setup
    /// tabCoordinator.pages = MyTabs.sortedByPosition()
    /// ```
    ///
    /// ## Performance Notes
    /// - This method performs a sort operation on all cases each time it's called
    /// - Consider caching the result if called frequently
    /// - The sorting complexity is O(n log n) where n is the number of cases
    static func sortedByPosition() -> [Self] {
        Self.allCases.sorted(by: { $0.position < $1.position })
    }
}

/// A type alias representing a complete tab page definition.
///
/// `TabPage` combines three essential protocols to create a fully functional tab page:
/// - `PageDataSource`: Provides the visual representation and positioning
/// - `TabNavigationRouter`: Provides the coordinator creation functionality
/// - `SCEquatable`: Provides equality comparison capabilities
///
/// This type alias simplifies the declaration of tab page types and ensures they have
/// all the necessary functionality for tab-based navigation. It serves as the primary
/// interface for defining tabs in the SUICoordinator framework.
///
/// ## Key Capabilities
/// - **Visual Representation**: Through PageDataSource, provides title, icon, and positioning
/// - **Navigation Management**: Through TabNavigationRouter, creates and manages coordinators
/// - **Equality Comparison**: Through SCEquatable, enables proper tab identification and comparison
///
/// ## Usage Example
/// ```swift
/// enum AppTabs: TabPage {
///     case home, search, profile
///
///     // PageDataSource requirements
///     var position: Int { /* implementation */ }
///     var dataSource: TabDataSource { /* implementation */ }
///
///     // TabNavigationRouter requirements
///     func coordinator() -> (any CoordinatorType) { /* implementation */ }
///
///     // SCEquatable is automatically satisfied for enums
/// }
/// ```
///
/// ## Best Practices
/// - Use enums to implement TabPage for type safety and exhaustive case handling
/// - Ensure position values are unique and sequential for predictable tab ordering
/// - Create dedicated coordinator types for each tab to maintain separation of concerns
/// - Consider the data source pattern for complex tab visual representations
public typealias TabPage = PageDataSource & TabNavigationRouter & SCEquatable
