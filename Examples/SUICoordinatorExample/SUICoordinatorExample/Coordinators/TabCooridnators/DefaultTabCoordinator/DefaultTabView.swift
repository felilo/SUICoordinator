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

/// A SwiftUI view that renders a native `TabView` driven by a `TabCoordinator`.
///
/// `DefaultTabView` is the standard tab-bar container for this example app. It reads
/// pages, selection state, and badge updates directly from the coordinator and renders
/// them using SwiftUI's native `TabView` API — including the iOS 18 `Tab` API with
/// automatic fallback to the legacy `.tabItem` API on earlier OS versions.
///
/// **Badge propagation**
/// This view injects a `\.setTabBadge` environment closure on the outermost `ZStack`
/// so that screens nested deep inside a `NavigationStack` can update a tab badge without
/// holding a coordinator reference. (`NavigationStack` does **not** propagate
/// `@Environment` values, so the injection point must be above the `TabView`.)
///
/// **Usage**
/// `DefaultTabView` is created by `DefaultTabCoordinator` and passed to
/// `TabCoordinator.init(viewContainer:)`. You do not normally instantiate it directly.
struct DefaultTabView: View {
    
    // ---------------------------------------------------------------------
    // MARK: Typealiases
    // ---------------------------------------------------------------------
    
    /// Concrete coordinator type this view is bound to.
    typealias DataSource = TabCoordinator<MyTabPage>
    
    /// The data source that provides tab coordinator functionality.
    ///
    /// This object manages the pages, current page selection, and badge updates.
    @State var dataSource: DataSource
    
    /// The current badge states for all tabs.
    ///
    /// This array maintains the badge values for each tab, synchronized with the pages array.
    @State var badges = [DataSource.BadgeItem]()
    
    /// Initializes a new tab view coordinator.
    ///
    /// - Parameters:
    ///   - dataSource: The tab coordinator that provides the data and coordination logic.
    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    // ---------------------------------------------------------------------
    // MARK: View
    // ---------------------------------------------------------------------
    
    /// The main view body that creates the tab interface.
    ///
    /// This view creates a SwiftUI `TabView` with tabs generated from the pages array.
    /// It handles automatic updates when pages change and manages badge synchronization.
    var body: some View {
        ZStack {
            if #available(iOS 18, *) {
                modernTabContainerView()
            } else {
                legacyTabContainerView()
            }
        }
        // Injects the badge setter closure so any child view — even one buried
        // inside a NavigationStack — can update a tab badge without holding a
        // reference to the coordinator. Must be applied here on the ZStack that
        // wraps the TabView; applying it inside the TabView's content would make
        // it invisible to NavigationStack children (NavigationStack does NOT
        // propagate @Environment downward the way TabView does).
        .environment(\.setTabBadge, badgeSetter)
        .onChange(of: dataSource.pages) { _, pages in
            badges = pages.map { (nil, $0) }
        }
        .task {
            badges = dataSource.pages.map { (nil, $0) }
            
            for await badge in dataSource.badges {
                guard let index = getBadgeIndex(page: badge.1)
                else { return }
                
                badges[index].value = badge.0
            }
        }
    }
    
    // ---------------------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------------------
    
    /// Renders the tab interface using the pre-iOS 18 `.tabItem` API.
    ///
    /// Each page is wrapped in `.tabItem { Label(...) }` with a `.badge()` modifier
    /// and a `.tag()` so that `TabView(selection:)` can track the active page.
    @ViewBuilder
    private func legacyTabContainerView() -> some View {
        TabView(selection: $dataSource.currentPage){
            ForEach(dataSource.pages, id: \.id) { page in
                dataSource.getCoordinator(with: page)?.viewAsAnyView()
                    .tabItem { buildLabelTab(with: page) }
                    .badge(badge(of: page))
                    .tag(page)
            }
        }
    }
    
    /// Renders the tab interface using the iOS 18+ `Tab` API.
    ///
    /// Each page becomes a `Tab(value:content:label:)` with `.badge()` applied directly
    /// on the `Tab` (not inside its content closure — see the skill notes on badge placement)
    /// and `.customizationID` for tab-bar customization support.
    @available(iOS 18, *)
    @ViewBuilder
    private func modernTabContainerView() -> some View {
        TabView(selection: $dataSource.currentPage) {
            ForEach(dataSource.pages, id: \.id) { page in
                if let coordinator = dataSource.getCoordinator(with: page) {
                    Tab.init(
                        value: page,
                        content: { coordinator.viewAsAnyView() },
                        label: { buildLabelTab(with: page) }
                    )
                    .badge(badge(of: page))
                    .customizationID(page.id)
                }
            }
        }
    }
    
    /// Builds the `Label` used for both the legacy `.tabItem` and the iOS 18 `Tab` label closure.
    ///
    /// Delegates to `page.dataSource` for the title and icon views, keeping the tab-item
    /// rendering logic in one place regardless of which API branch is active.
    private func buildLabelTab(with page: DataSource.Page) -> some View {
        Label(title: { page.dataSource.title }, icon: { page.dataSource.icon } )
    }
    
    /// Retrieves the badge information for a specific page.
    ///
    /// - Parameter page: The page to get badge information for.
    /// - Returns: The badge item for the page, or `nil` if no badge is set or the page is not found.
    private func badge(of page: MyTabPage) -> Int {
        guard let index = getBadgeIndex(page: page), let number = Int(badges[index].value ?? "") else {
            return 0
        }
        return number
    }
    
    /// Gets the index of a page in the badges array.
    ///
    /// - Parameter page: The page to find the index for.
    /// - Returns: The index of the page in the badges array, or `nil` if not found.
    private func getBadgeIndex(page: MyTabPage) -> Int? {
        badges.firstIndex(where: { $0.1 == page })
    }
    
    /// A weak-capturing closure forwarded to the coordinator's `setBadge(for:with:)`.
    ///
    /// Captured weakly so the view does not extend the coordinator's lifetime.
    /// This closure is injected into the environment via `\.setTabBadge` and consumed
    /// by child views that need to trigger a badge update (e.g. `NavigationActionListView`).
    private var badgeSetter: (DataSource.BadgeItem) -> Void {
        { [weak dataSource] item in
            dataSource?.setBadge(for: item.page, with: item.value)
        }
    }
}

// ---------------------------------------------------------------------
// MARK: Environment key
// ---------------------------------------------------------------------

/// `EnvironmentKey` that carries the tab-badge setter closure for the default `TabView`-based tab bar.
///
/// `DefaultTabView` injects a concrete closure via `.environment(\.setTabBadge, badgeSetter)`.
/// Child views anywhere in the subtree — including those inside a `NavigationStack` — can read
/// `@Environment(\.setTabBadge)` and call it to update a badge without a direct coordinator reference.
///
/// The default value is `nil` so that views used outside a tab context compile without changes.
struct TabBadgeKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: ((TabCoordinator<MyTabPage>.BadgeItem) -> Void)? = nil
}

extension EnvironmentValues {
    /// A closure that updates a tab badge on the default `TabView`-based tab bar.
    ///
    /// Call it with a `BadgeItem` tuple `(value: String?, page: MyTabPage)`:
    /// ```swift
    /// @Environment(\.setTabBadge) private var setTabBadge
    /// setTabBadge?(("3", .first))   // sets badge "3" on the .first tab
    /// setTabBadge?((nil, .first))   // clears the badge
    /// ```
    /// This is `nil` when the view is not embedded inside a `DefaultTabView`.
    var setTabBadge: ((TabCoordinator<MyTabPage>.BadgeItem) -> Void)? {
        get { self[TabBadgeKey.self] }
        set { self[TabBadgeKey.self] = newValue }
    }
}
