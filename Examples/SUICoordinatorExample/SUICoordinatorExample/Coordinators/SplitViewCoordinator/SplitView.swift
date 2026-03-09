//
//  SplitView.swift
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

/// A `NavigationSplitView`-based container for `TabCoordinator`.
///
/// This view replaces the standard `TabView` container with a two-column split
/// layout: the sidebar lists available pages, and the detail column renders the
/// coordinator view for the currently selected page.
///
/// It mirrors the structure of `DefaultTabView` / `CustomTabView` — the only
/// difference is the shell (`NavigationSplitView` vs `TabView`). All coordinator
/// lifecycle management, page switching, and child coordinator routing come from
/// `TabCoordinatorType` for free.
///
/// On iPhone, `NavigationSplitView` collapses to a single column. The
/// `preferredCompactColumn` binding is used to programmatically push to the
/// detail column when the user taps a sidebar row, and the system back button
/// automatically returns to the sidebar.
struct SplitView<DataSource: TabCoordinatorType>: View where DataSource.DataSourcePage == SplitViewTabPageDataSource {

    typealias Page = DataSource.Page

    // ---------------------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------------------

    @State var dataSource: DataSource
    /// Tracks the sidebar selection so `List` can apply the standard system
    /// highlight to the active row.
    @State private var selectedPage: Page?
    /// Controls which column is on top when the split view collapses on iPhone.
    /// Set to `.detail` after a sidebar tap so the detail column is shown.
    @State private var preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // ---------------------------------------------------------------------
    // MARK: Init
    // ---------------------------------------------------------------------

    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    // ---------------------------------------------------------------------
    // MARK: View
    // ---------------------------------------------------------------------

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredCompactColumn) {
            sidebarView()
        } detail: {
            detailView()
        }
    }

    // ---------------------------------------------------------------------
    // MARK: Helper views
    // ---------------------------------------------------------------------

    @ViewBuilder
    private func sidebarView() -> some View {
        List(dataSource.pages, id: \.id, selection: $selectedPage) { page in
            NavigationLink(value: page) {
                Label {
                    page.dataSource.title
                } icon: {
                    page.dataSource.icon
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Menu")
        .navigationDestination(for: Page.self) { _ in
            // Detail is rendered in the split view's detail column, not here.
            // This destination is only reached on compact (iPhone) where the
            // split view acts as a single navigation stack.
            detailView()
        }
        .onChange(of: selectedPage) { _, page in
            guard let page else { return }
            dataSource.setCurrentPage(page)
            if horizontalSizeClass == .compact {
                preferredCompactColumn = .detail
            }
        }
    }

    @ViewBuilder
    private func detailView() -> some View {
        if let coordinator = dataSource.getCoordinator(with: dataSource.currentPage) {
            coordinator.viewAsAnyView()
        } else {
            ContentUnavailableView("Select a section", systemImage: "sidebar.left")
        }
    }
}

#Preview {
    SplitView(dataSource: SplitViewCoordinator(currentPage: .home))
}
