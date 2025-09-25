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

struct CustomTabView<DataSource: TabCoordinatorType>: View where DataSource.DataSourcePage == MyTabPageDataSource {
    
    // ---------------------------------------------------------------------
    // MARK: Typealias
    // ---------------------------------------------------------------------
    
    
    typealias Page = DataSource.Page
    typealias BadgeItem = DataSource.BadgeItem
    
    
    // ---------------------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------------------
    
    
    @StateObject private var dataSource: DataSource
    @State private var badges = [BadgeItem]()
    
    private let widthIcon: CGFloat = 22
    
    
    // ---------------------------------------------------------------------
    // MARK: Init
    // ---------------------------------------------------------------------
    
    
    init(dataSource: DataSource) {
        self._dataSource = .init(wrappedValue: dataSource)
    }
    
    
    // ---------------------------------------------------------------------
    // MARK: View
    // ---------------------------------------------------------------------
    
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            TabView(selection: $dataSource.currentPage) {
                ForEach(dataSource.pages, id: \.id, content: tabBarItem)
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
        }
        .ignoresSafeArea(.all, edges: [.leading, .trailing, .top])
        .onChange(of: dataSource.pages) { pages in
            badges = pages.map { (nil, $0) }
        }
        .onReceive(dataSource.badge) { (value, page) in
            guard let index = getBadgeIndex(page: page) else { return }
            badges[index].value = value
        }.task {
            badges = dataSource.pages.map { (nil, $0) }
        }
    }
    
    
    // ---------------------------------------------------------------------
    // MARK: Helper views
    // ---------------------------------------------------------------------
    
    
    @ViewBuilder
    func tabBarItem(page: Page) -> some View {
        if let item = dataSource.getCoordinator(with: page) {
            item.getView().asAnyView()
                .toolbar(.hidden, for: .tabBar)
                .tag(page)
        }
    }
    
    
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
    
    
    private func getBadge(page: Page) -> BadgeItem? {
        guard let index = getBadgeIndex(page: page) else {
            return nil
        }
        return badges[index]
    }
    
    
    private func getBadgeIndex(page: Page) -> Int? {
        badges.firstIndex(where: { $0.1 == page })
    }
    
    
    // ---------------------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------------------
    
    
    private func getWidthButton(with size: CGRect) -> CGFloat {
        size.width / CGFloat(dataSource.pages.count)
    }
}
