//
//  CustomTabView.swift
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

/// A SwiftUI view that renders a fully custom tab bar driven by a `TabCoordinator`.
///
/// `CustomTabView` replaces the system `TabView` chrome with a floating rounded-rect
/// bar overlaid at the bottom of the screen. The native `TabView` is still used as the
/// page container (for free swipe-between-tabs support), but its default tab bar is hidden
/// and substituted with `customTabView()`.
///
/// **Badge propagation**
/// This view injects a `\.setCustomTabBadge` environment closure on the outermost `ZStack`
/// so that screens nested deep inside a `NavigationStack` can update a badge on the custom
/// bar without holding a coordinator reference.
///
/// **Usage**
/// `CustomTabView` is created by `CustomTabCoordinator` and passed to
/// `TabCoordinator.init(viewContainer:)`. You do not normally instantiate it directly.
struct CustomTabView: View {
    
    // ---------------------------------------------------------------------
    // MARK: Typealiases
    // ---------------------------------------------------------------------
    
    /// Concrete coordinator type this view is bound to.
    typealias DataSource = TabCoordinator<MyTabPage>
    /// Convenience alias for the page type managed by the coordinator.
    typealias Page = DataSource.Page
    /// Convenience alias for the badge tuple `(value: String?, page: Page)`.
    typealias BadgeItem = DataSource.BadgeItem
    
    // ---------------------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------------------
    
    /// The coordinator that owns pages, selection state, and badge updates.
    @State private var dataSource: DataSource
    /// Local mirror of badge state, kept in sync with `dataSource.badges` via `.task`.
    @State private var badges = [BadgeItem]()
    
    /// Fixed width used when sizing each tab-bar button icon (currently unused; reserved for future icon sizing).
    private let widthIcon: CGFloat = 22
    
    
    // ---------------------------------------------------------------------
    // MARK: Init
    // ---------------------------------------------------------------------
    
    /// Creates a `CustomTabView` bound to the given coordinator.
    ///
    /// - Parameter dataSource: The tab coordinator that provides pages, selection, and badge updates.
    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    
    // ---------------------------------------------------------------------
    // MARK: View
    // ---------------------------------------------------------------------
    
    /// The main view body.
    ///
    /// Layers a native `TabView` (page container) below the floating custom tab bar,
    /// injects the badge setter into the environment, and starts the badge-update stream.
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            TabView(selection: $dataSource.currentPage) {
                ForEach(dataSource.pages, id: \.id) { page in
                    dataSource.getCoordinator(with: page)?.getView()
                        .asAnyView()
                        .tag(page)
                }
            }
            
            VStack() {
                Spacer()
                customTabView()
            }.background {
                RoundedRectangle(cornerRadius: 60)
                    .shadow(color: Color.black.opacity(0.5), radius: 5, y: 4)
            }
            .frame(maxWidth: .infinity, maxHeight: 60)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        // Injects the badge setter closure so child views can update a custom tab
        // badge without holding a coordinator reference. Applied on the outermost
        // ZStack (above the TabView) so the closure is visible to views inside
        // NavigationStacks — NavigationStack does NOT forward @Environment values.
        .environment(\.setCustomTabBadge, badgeSetter)
        .ignoresSafeArea(.all, edges: [.all])
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
    // MARK: Helper views
    // ---------------------------------------------------------------------
    
    
    /// Builds a single tappable item for the custom tab bar.
    ///
    /// Tapping the button calls `dataSource.setCurrentPage(_:)` to switch tabs.
    /// The icon and title tint changes to blue for the active page and white otherwise.
    /// A badge overlay is applied via `customBadge(with:)`.
    ///
    /// - Parameters:
    ///   - page: The tab page this item represents.
    ///   - size: The global frame of the tab bar container, used to evenly divide button widths.
    private func customTabBarItem(@State page: Page, size: CGRect) -> some View {
        Button {
            dataSource.setCurrentPage(page)
        } label: {
            ZStack(alignment: .bottom) {
                VStack(alignment: .center , spacing: 2) {
                    page.dataSource.icon
                    page.dataSource.title
                }.foregroundColor(dataSource.currentPage == page ? .blue : .white)
            }
        }
        .frame(width: getWidthButton(with: size))
        .overlay( customBadge(with: page) )
    }
    
    
    /// Renders a red capsule badge overlay for the given page, if a badge value is set.
    ///
    /// Returns `EmptyView` when the page has no badge (`value == nil`).
    /// The badge is offset to sit in the top-right corner of the tab icon.
    @ViewBuilder
    func customBadge(with page: Page) -> some View {
        if let value = getBadge(page: page)?.value {
            HStack(alignment: .top) {
                Text(value)
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .padding(5)
            }
            .frame(height: 40 / 2 )
            .background(.red)
            .clipShape(Capsule())
            .offset(x: 15, y:  -15)
        }
    }
    
    
    /// Builds the full floating tab bar by laying out one `customTabBarItem` per page
    /// inside a `GeometryReader` so each item receives an equal share of the bar width.
    @ViewBuilder
    func customTabView() -> some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(dataSource.pages, id: \.id) {
                    customTabBarItem(
                        page: $0,
                        size: proxy.frame(in: .global)
                    )
                }
            }
        }
    }
    
    
    /// Returns the `BadgeItem` for the given page, or `nil` if not found.
    private func getBadge(page: Page) -> BadgeItem? {
        guard let index = getBadgeIndex(page: page) else {
            return nil
        }
        return badges[index]
    }
    
    
    /// Returns the index of the given page in the `badges` array, or `nil` if not found.
    private func getBadgeIndex(page: Page) -> Int? {
        badges.firstIndex(where: { $0.1 == page })
    }
    
    
    // ---------------------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------------------
    
    
    /// Computes the width of a single tab-bar button by dividing the total bar width evenly
    /// across all pages.
    private func getWidthButton(with size: CGRect) -> CGFloat {
        size.width / CGFloat(dataSource.pages.count)
    }
    
    /// A weak-capturing closure forwarded to the coordinator's `setBadge(for:with:)`.
    ///
    /// Captured weakly so the view does not extend the coordinator's lifetime.
    /// Injected into the environment via `\.setCustomTabBadge` and consumed by child
    /// views that need to trigger a badge update on the custom tab bar
    /// (e.g. `NavigationActionListDetailView`).
    private var badgeSetter: (BadgeItem) -> Void {
        { [weak dataSource] item in
            dataSource?.setBadge(for: item.page, with: item.value)
        }
    }
}

// ---------------------------------------------------------------------
// MARK: Preview
// ---------------------------------------------------------------------

#Preview {
    CustomTabView(dataSource: DefaultTabCoordinator())
}


// ---------------------------------------------------------------------
// MARK: Environment key
// ---------------------------------------------------------------------

/// `EnvironmentKey` that carries the tab-badge setter closure for the custom rounded-rect tab bar.
///
/// `CustomTabView` injects a concrete closure via `.environment(\.setCustomTabBadge, badgeSetter)`.
/// Child views anywhere in the subtree — including those inside a `NavigationStack` — can read
/// `@Environment(\.setCustomTabBadge)` and call it to update a badge without a direct coordinator reference.
///
/// The default value is `nil` so that views used outside a custom tab context compile without changes.
struct CustomTabBadgeKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: ((TabCoordinator<MyTabPage>.BadgeItem) -> Void)? = nil
}

extension EnvironmentValues {
    /// A closure that updates a tab badge on the custom rounded-rect tab bar.
    ///
    /// Call it with a `BadgeItem` tuple `(value: String?, page: MyTabPage)`:
    /// ```swift
    /// @Environment(\.setCustomTabBadge) var customTabBadge
    /// customTabBadge?(("5", .first))   // sets badge "5" on the .first tab
    /// customTabBadge?((nil, .first))   // clears the badge
    /// ```
    /// This is `nil` when the view is not embedded inside a `CustomTabView`.
    var setCustomTabBadge: ((TabCoordinator<MyTabPage>.BadgeItem) -> Void)? {
        get { self[CustomTabBadgeKey.self] }
        set { self[CustomTabBadgeKey.self] = newValue }
    }
}
