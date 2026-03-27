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

/// A SwiftUI view that renders a fully custom floating-pill tab bar driven by a `TabCoordinator`.
///
/// `CustomTabView` avoids `TabView` entirely — which eliminates the native tab bar
/// visibility problem. All coordinator views are kept alive simultaneously (mirroring
/// `TabView`'s behaviour) with only the active page visible and interactive, preserving
/// each tab's `NavigationStack` state across switches without any flash.
///
/// The tab bar is a floating `ultraThinMaterial` capsule. The selected tab shows an inner
/// white pill with icon + label side by side; inactive tabs show only the icon.
///
/// **Badge propagation**
/// Injects a `\.setCustomTabBadge` environment closure above the content so that screens
/// nested inside a `NavigationStack` can update a badge without a direct coordinator reference.
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
    /// All coordinator views are kept alive simultaneously (mirroring `TabView` behaviour)
    /// with only the active page visible and interactive. The floating pill tab bar is
    /// inserted via `.safeAreaInset(edge: .bottom)` so content never scrolls behind it
    /// and the bar sits correctly above the home indicator on all devices.
    var body: some View {
        ZStack {
            // All coordinator views are kept alive in the hierarchy simultaneously —
            // mirroring TabView's internal behaviour. Only the active page is visible
            // and interactive; inactive pages are hidden via opacity and excluded from
            // hit-testing so they don't intercept touches. This preserves each tab's
            // NavigationStack state across switches without using TabView at all.
            ForEach(dataSource.pages, id: \.id) { page in
                if let coordinator = dataSource.getCoordinator(with: page) {
                    coordinator.viewAsAnyView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(dataSource.currentPage == page ? 1 : 0)
                        .allowsHitTesting(dataSource.currentPage == page)
                }
            }
        }
        // Inserts the tab bar at the bottom and automatically adjusts the content's
        // safe area so views never scroll behind the bar.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            customTabView()
        }
        // Injects the badge setter closure so child views can update a custom tab
        // badge without holding a coordinator reference. Applied on the outermost
        // ZStack so the closure is visible to views inside NavigationStacks —
        // NavigationStack does NOT forward @Environment values.
        .environment(\.setCustomTabBadge, badgeSetter)
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
    
    /// Builds a single tappable pill item for the floating tab bar.
    ///
    /// The selected tab shows icon + label side by side inside a white inner pill.
    /// Inactive tabs show only the icon. The label fades in/out and the pill background
    /// appears/disappears via `.animation(_:value:)`.
    ///
    /// Content switches instantly (no `withAnimation`) to avoid the opacity flash
    /// that occurs when two views are partially transparent at the same time.
    ///
    /// - Parameter page: The tab page this item represents.
    private func customTabBarItem(page: Page) -> some View {
        let isSelected = dataSource.currentPage == page
        return Button {
            // Instant switch — no withAnimation prevents the opacity flash on the
            // content layer while keeping the button visuals animated below.
            dataSource.setCurrentPage(page)
        } label: {
            HStack(spacing: 6) {
                page.dataSource.icon
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                
                if isSelected {
                    page.dataSource.title
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.primary)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color(.systemBackground) : Color.clear, in: Capsule())
            // Animates only the button visuals (tint + inner pill) — not the content swap.
            .animation(.snappy(duration: 0.25), value: dataSource.currentPage)
        }
        .overlay(customBadge(with: page))
    }
    
    /// Renders a red capsule badge overlay for the given page, if a badge value is set.
    ///
    /// Returns `EmptyView` when the page has no badge (`value == nil`).
    @ViewBuilder
    func customBadge(with page: Page) -> some View {
        if let value = getBadge(page: page)?.value {
            HStack(alignment: .top) {
                Text(value)
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .padding(5)
            }
            .frame(height: 40 / 2)
            .background(.red)
            .clipShape(Capsule())
            .offset(x: 15, y: -15)
        }
    }
    
    /// Builds the floating pill tab bar.
    ///
    /// All tab items sit inside a single outer capsule with `ultraThinMaterial` background.
    /// The selected item renders an inner white pill (via `customTabBarItem`).
    /// A drop shadow lifts the bar visually off the content below.
    @ViewBuilder
    func customTabView() -> some View {
        HStack(spacing: 4) {
            ForEach(dataSource.pages, id: \.id) { page in
                customTabBarItem(page: page)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.15), radius: 16, y: 6)
        .padding(.bottom, 12)
    }
    
    // ---------------------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------------------
    
    /// Returns the `BadgeItem` for the given page, or `nil` if not found.
    private func getBadge(page: Page) -> BadgeItem? {
        guard let index = getBadgeIndex(page: page) else { return nil }
        return badges[index]
    }
    
    /// Returns the index of the given page in the `badges` array, or `nil` if not found.
    private func getBadgeIndex(page: Page) -> Int? {
        badges.firstIndex(where: { $0.1 == page })
    }
    
    /// A weak-capturing closure forwarded to the coordinator's `setBadge(for:with:)`.
    ///
    /// Captured weakly so the view does not extend the coordinator's lifetime.
    /// Injected into the environment via `\.setCustomTabBadge` and consumed by child
    /// views that need to trigger a badge update (e.g. `NavigationActionListDetailView`).
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

/// `EnvironmentKey` that carries the tab-badge setter closure for the custom tab bar.
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
    /// A closure that updates a tab badge on the custom tab bar.
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
