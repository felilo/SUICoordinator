//
//  CustomTabbarView.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
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
