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
/// including its visual representation (title and icon) and its position in the tab bar.
///
/// Types conforming to this protocol define how each tab appears to the user and where it should
/// be positioned relative to other tabs.
public protocol PageDataSource: SCHashable {
    
    /// A type alias representing a SwiftUI view.
    ///
    /// This is used to ensure type safety when working with SwiftUI views in the context of tab pages.
    typealias View = (any SwiftUI.View)
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The title view for the page.
    ///
    /// This view is displayed as the text label for the tab item. It's typically a `Text` view
    /// but can be any SwiftUI view that represents the tab's title.
    ///
    /// - Note: Use the `@ViewBuilder` attribute to enable view builder syntax.
    @ViewBuilder
    var title: View  { get }
    
    /// The icon view for the page.
    ///
    /// This view is displayed as the visual icon for the tab item. It's typically an `Image` view
    /// (often using SF Symbols) but can be any SwiftUI view that represents the tab's icon.
    ///
    /// - Note: Use the `@ViewBuilder` attribute to enable view builder syntax.
    @ViewBuilder
    var icon: View { get }
    
    /// The position of the page in the tab bar.
    ///
    /// This integer value determines the order in which tabs appear in the tab bar interface.
    /// Lower values appear first (leftmost in horizontal layouts).
    ///
    /// - Important: Position values should be unique across all tabs to ensure proper ordering.
    var position: Int { get }
}

/// An extension for `PageDataSource` to provide utility methods for types that are also `CaseIterable`.
public extension PageDataSource where Self: CaseIterable {
    
    /// Sorts all cases of `PageDataSource` by their position.
    ///
    /// This method provides a convenient way to get all available pages sorted by their
    /// position property, which is useful when setting up the tab interface.
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
    /// ```
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
/// all the necessary functionality for tab-based navigation.
public typealias TabPage = PageDataSource & TabNavigationRouter & SCEquatable
