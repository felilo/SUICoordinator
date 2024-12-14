//
//  CustomTabbarView.swift
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

struct CustomTabbarView: View {
    
    // ---------------------------------------------------------------------
    // MARK: Typealias
    // ---------------------------------------------------------------------
    
    
    typealias Page = MyTabbarPage
    typealias BadgeItem = (value: String?, page: Page)
    
    
    // ---------------------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------------------
    
    
    @StateObject private var viewModel: TabbarCoordinator<Page>
    @State private var currentPage: Page
    @State private var pages: [Page]
    @State var badges = [BadgeItem]()
    
    let widthIcon: CGFloat = 22
    
    
    // ---------------------------------------------------------------------
    // MARK: Init
    // ---------------------------------------------------------------------
    
    
    init(viewModel: TabbarCoordinator<Page>) {
        self._viewModel = .init(wrappedValue: viewModel)
        currentPage = viewModel.currentPage
        pages = viewModel.pages
    }
    
    
    // ---------------------------------------------------------------------
    // MARK: View
    // ---------------------------------------------------------------------
    
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            TabView(selection: $currentPage) {
                ForEach(pages, id: \.id, content: tabBarItem)
            }
            
            VStack() {
                Spacer()
                customTabbar()
            }.background(
                .gray.opacity(0.5),
                in: RoundedRectangle(cornerRadius: 0, style: .continuous)
            )
            .frame(maxWidth: .infinity, maxHeight: 60)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .padding(.horizontal, 10)
        }
        .ignoresSafeArea(.all, edges: [.leading, .trailing, .top])
        .onReceive(viewModel.$currentPage) { currentPage = $0 }
        .onReceive(viewModel.$pages) { pages in
            self.pages = pages
            badges = pages.map { (nil, $0) }
        }
        .onReceive(viewModel.setBadge) { (value, page) in
            guard let index = getBadgeIndex(page: page) else { return }
            badges[index].value = value
        }
    }
    
    
    // ---------------------------------------------------------------------
    // MARK: Helper views
    // ---------------------------------------------------------------------
    
    
    @ViewBuilder
    func tabBarItem(page: Page) -> some View {
        if let item = viewModel.getCoordinator(with: page.position) {
            AnyView( item.getView() )
                .toolbar(.hidden)
                .tag(page)
        }
    }
    
    
    private func customTabBarItem(@State page: Page, size: CGRect) -> some View {
        Button {
            viewModel.setCurrentPage(page)
        } label: {
            ZStack(alignment: .bottom) {
                VStack(alignment: .center , spacing: 2) {
                    AnyView(page.icon)
                    AnyView(page.title)
                }.foregroundColor(currentPage == page ? .blue : .black)
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
    func customTabbar() -> some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(pages, id: \.id) {
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
        size.width / CGFloat(pages.count)
    }
}
