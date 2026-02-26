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

struct RouterView<C: CoordinatorType>: View {
    
    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------
    
    @StateObject private var viewModel: Router<C.Route>
    private  let coordinator: C
    
    // --------------------------------------------------------------------
    // MARK: Constructor
    // --------------------------------------------------------------------
    
    public init(coordinator: C) {
        self._viewModel = .init(wrappedValue: coordinator.router)
        self.coordinator = coordinator
    }
    
    // --------------------------------------------------------------------
    // MARK: View
    // --------------------------------------------------------------------
    
    var body: some View {
        ZStack { buildBody() }
            .clearModalBackground(coordinator.isTabCoordinable)
    }
    
    // --------------------------------------------------------------------
    // MARK: View helper functions
    // --------------------------------------------------------------------
    
    
    @ViewBuilder
    private func buildBody() -> some View {
        Group {
            if coordinator.isTabCoordinable {
                viewModel.mainView
            } else if let mainView = viewModel.mainView  {
                let view = NavigationStack(
                    path: $viewModel.items,
                    root: { mainView.navigationDestination(for: C.Route.self) { $0 } }
                )
                .transaction { $0.disablesAnimations = !viewModel.animated }
                .onChange(of: viewModel.items, perform: onChangeItems)
                
                addSheetTo(view: view)
            }
        }
    }
    
    @ViewBuilder
    private func addSheetTo(view: (some View)?) -> some View {
        view.environmentObject(coordinator)
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
    
    private func onChangeItems(_ value: [C.Route]) {
        Task { await viewModel.syncItems() }
    }
}