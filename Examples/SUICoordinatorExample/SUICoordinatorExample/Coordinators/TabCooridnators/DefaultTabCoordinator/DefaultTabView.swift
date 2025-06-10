//
//  TabCoordinatorView.swift
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

/// A SwiftUI view that provides the default tab interface for tab coordinators.
///
/// `TabViewCoordinator` is the default implementation of a tab interface that works with
/// tab coordinators. It creates a native SwiftUI `TabView` and manages the coordination
/// between the tab interface and the underlying tab coordinator.
///
/// This view handles:
/// - Displaying tabs with their associated content views
/// - Managing tab selection and synchronization with the coordinator
/// - Badge management for individual tabs
/// - Automatic updates when pages or current page changes
///
/// The view automatically synchronizes with the data source's published properties and
/// responds to badge update events through the `setBadge` publisher.
///
/// - Note: This is the default view used by `TabCoordinator` when a custom `viewContainer` is not provided.
public struct DefaultTabView<DataSource: TabCoordinatorType>: View where DataSource.DataSourcePage == MyTabPageDataSource {
    
    /// Type alias for the page type used by the data source.
    public typealias Page = DataSource.Page
    
    /// Type alias for badge items used by the data source.
    public typealias BadgeItem = DataSource.BadgeItem
    
    // ---------------------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------------------
    
    /// The data source that provides tab coordinator functionality.
    ///
    /// This object manages the pages, current page selection, and badge updates.
    @StateObject var dataSource: DataSource
    
    /// The current badge states for all tabs.
    ///
    /// This array maintains the badge values for each tab, synchronized with the pages array.
    @State var badges = [BadgeItem]()
    
    /// The current array of pages to display as tabs.
    ///
    /// This array is synchronized with the data source's pages and updates when pages change.
    @State var pages = [Page]()
    
    /// The currently selected page.
    ///
    /// This value is bound to the TabView's selection and synchronized with the data source.
    @State var currentPage: Page
    
    /// Initializes a new tab view coordinator.
    ///
    /// - Parameters:
    ///   - dataSource: The tab coordinator that provides the data and coordination logic.
    ///   - currentPage: The initial page to select. Should match the data source's current page.
    public init(dataSource: DataSource) {
        self._dataSource = .init(wrappedValue: dataSource)
        self.currentPage = dataSource.currentPage
    }
    
    // ---------------------------------------------------------------------
    // MARK: View
    // ---------------------------------------------------------------------
    
    /// The main view body that creates the tab interface.
    ///
    /// This view creates a SwiftUI `TabView` with tabs generated from the pages array.
    /// It handles automatic updates when pages change and manages badge synchronization.
    public var body: some View {
        TabView(selection: $currentPage){
            ForEach(pages, id: \.id, content: tabBarItem)
        }
        .onChange(of: dataSource.pages) { pages in
            self.pages = pages
            badges = pages.map { (nil, $0) }
        }
        .onChange(of: dataSource.currentPage) { page in
            currentPage = page
        }
        .onReceive(dataSource.setBadge) { (value, page) in
            guard let index = getBadgeIndex(page: page) else { return }
            badges[index].value = value
        }
        .task {
            pages = dataSource.pages
            badges = pages.map { (nil, $0) }
        }
    }
    
    // ---------------------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------------------
    
    /// Creates a tab bar item for a specific page.
    ///
    /// This method creates a complete tab item including the content view, tab item label,
    /// badge (if applicable), and proper tagging for selection management.
    ///
    /// - Parameter page: The page to create a tab item for.
    /// - Returns: A SwiftUI view representing the complete tab item.
    @ViewBuilder
    func tabBarItem(with page: Page) -> some View {
        if let item = dataSource.getCoordinator(with: page.position) {
            item.getView().asAnyView()
                .tabItem {
                    Label(
                        title: { page.dataSource.title },
                        icon: { page.dataSource.icon } )
                }
                .badge(badge(of: page)?.value)
                .tag(page)
        }
    }
    
    /// Retrieves the badge information for a specific page.
    ///
    /// - Parameter page: The page to get badge information for.
    /// - Returns: The badge item for the page, or `nil` if no badge is set or the page is not found.
    private func badge(of page: Page) -> BadgeItem? {
        guard let index = getBadgeIndex(page: page) else {
            return nil
        }
        return badges[index]
    }
    
    /// Gets the index of a page in the badges array.
    ///
    /// - Parameter page: The page to find the index for.
    /// - Returns: The index of the page in the badges array, or `nil` if not found.
    private func getBadgeIndex(page: Page) -> Int? {
        badges.firstIndex(where: { $0.1 == page })
    }
}
