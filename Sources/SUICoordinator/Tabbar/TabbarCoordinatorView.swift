//
//  TabbarCoordinatorView.swift
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
import Foundation

struct TabbarCoordinatorView<DataSource: TabbarCoordinatorType>: View where DataSource.Page: TabbarPage {
    
    typealias Page = DataSource.Page
    typealias BadgeItem = DataSource.BadgeItem
    
    // ---------------------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------------------
    
    @StateObject var dataSource: DataSource
    @State var badges = [BadgeItem]()
    @State var pages = [Page]()
    @State var currentPage: Page
    
    init(dataSource: DataSource, currentPage: Page) {
        self._dataSource = .init(wrappedValue: dataSource)
        self.currentPage = dataSource.currentPage
    }
    
    // ---------------------------------------------------------------------
    // MARK: View
    // ---------------------------------------------------------------------
    
    public var body: some View {
        TabView(selection: $dataSource.currentPage){
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
    
    @ViewBuilder
    func tabBarItem(with page: Page) -> some View {
        if let item = dataSource.getCoordinator(with: page.position) {
            AnyView( item.getView() )
                .tabItem {
                    Label(
                        title: { AnyView(page.title) },
                        icon: { AnyView(page.icon) } )
                }
                .badge(badge(of: page)?.value)
                .tag(page)
        }
    }
    
    private func badge(of page: Page) -> BadgeItem? {
        guard let index = getBadgeIndex(page: page) else {
            return nil
        }
        return badges[index]
    }
    
    private func getBadgeIndex(page: Page) -> Int? {
        badges.firstIndex(where: { $0.1 == page })
    }
}
