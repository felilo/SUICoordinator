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

struct CustomTabbarView: View {
    
    // ---------------------------------------------------------------------
    // MARK: Typealias
    // ---------------------------------------------------------------------
    
    
    typealias Page = MyTabbarPage
    
    
    // ---------------------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------------------
    
    
    @StateObject private var viewModel: CustomTabbarViewModel
    let widthIcon: CGFloat = 22
    
    
    // ---------------------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------------------
    
    
    init(viewModel: CustomTabbarViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    
    // ---------------------------------------------------------------------
    // MARK: View
    // ---------------------------------------------------------------------
    
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            TabView(selection: $viewModel.currentPage) {
                ForEach(viewModel.pages, id: \.self, content: makeTabView)
            }
            
            VStack() {
                Spacer()
                customTabbar()
            }.background(
                .gray.opacity(0.5),
                in: RoundedRectangle(cornerRadius: 0, style: .continuous)
            ).frame(maxWidth: .infinity, maxHeight: 60)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.horizontal, 10)
        }.ignoresSafeArea(.all, edges: [.leading, .trailing, .top])
    }
    
    
    // ---------------------------------------------------------------------
    // MARK: Helper views
    // ---------------------------------------------------------------------
    
    
    @ViewBuilder
    func makeTabView(page: Page) -> some View {
        if let item = viewModel.getCoordinator?(page.position) {
            AnyView( item.view )
                .toolbar(.hidden)
                .tag(page)
        }
    }
    
    
    private func tabbarButton(@State page: Page, size: CGRect) -> some View {
        Button {
            viewModel.setCurrentPage(page)
        } label: {
            
            ZStack(alignment: .bottom) {
                VStack(alignment: .center , spacing: 2) {
                    AnyView(page.icon)
                    AnyView(page.title)
                }.foregroundColor(viewModel.currentPage == page ? .blue : .black)
            }
        }.frame(width: getWidthButton(with: size))
    }
    
    
    func customTabbar() -> some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(viewModel.pages, id: \.self) {
                    tabbarButton(
                        page: $0,
                        size: proxy.frame(in: .global)
                    )
                }
            }
        }
    }
    
    
    // ---------------------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------------------
    
    
    private func getWidthButton(with size: CGRect) -> CGFloat {
        size.width / CGFloat(viewModel.pages.count)
    }
}
