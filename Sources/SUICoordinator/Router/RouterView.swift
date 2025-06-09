//
//  RouterView.swift
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
import Combine

struct RouterView<Router: RouterType>: View {
    
    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------
    
    @ObservedObject var viewModel: Router
    @State private var mainView: Router.Route?
    
    // --------------------------------------------------------------------
    // MARK: Constructor
    // --------------------------------------------------------------------
    
    public init(viewModel: Router) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    // --------------------------------------------------------------------
    // MARK: View
    // --------------------------------------------------------------------
    
    var body: some View {
        ZStack { buildBody() }
            .onViewDidLoad { onChangeFirstView(viewModel.mainView) }
    }
    
    // --------------------------------------------------------------------
    // MARK: View helper functions
    // --------------------------------------------------------------------
    
    
    @ViewBuilder
    private func buildBody() -> some View {
        Group {
            if viewModel.isTabCoordinable {
                addSheetTo(view: mainView)
            } else {
                let view = NavigationStack(
                    path: $viewModel.items,
                    root: { mainView.navigationDestination(for: Router.Route.self) { $0 } }
                )
                .transaction { $0.disablesAnimations = !viewModel.animated }
                .onChange(of: viewModel.items, perform: onChangeItems)
                
                addSheetTo(view: view)
            }
        }
    }
    
    @ViewBuilder
    private func addSheetTo(view: (some View)?) -> some View {
        view
            .onChange(of: viewModel.mainView, perform: onChangeFirstView)
            .sheetCoordinator(
                coordinator: viewModel.sheetCoordinator,
                onDissmis: { index in Task(priority: .high) { @MainActor [weak viewModel] in
                    await viewModel?.removeItemFromSheetCoordinator(at: index)
                }},
                onDidLoad: nil
            )
    }
    
    // --------------------------------------------------------------------
    // MARK: Helper functions
    // --------------------------------------------------------------------
    
    private func onChangeFirstView(_ value: Router.Route?) {
        guard let value else { return (mainView = nil) }
        
        mainView = value
    }
    
    private func onChangeItems(_ value: [Router.Route]) {
        Task { await viewModel.syncItems() }
    }
}
