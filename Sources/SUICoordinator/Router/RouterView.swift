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

@available(iOS 17.0, *)
struct RouterView<C: CoordinatorType>: View {
    
    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------
    
    private var coordinator: C
    private var viewModel: Router<C.Route> { coordinator.router }

    // --------------------------------------------------------------------
    // MARK: Constructor
    // --------------------------------------------------------------------
    
    public init(coordinator: C) {
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
            if coordinator.isTabCoordinable == true {
                viewModel.mainView
            } else if let view = viewModel.mainView {
                addSheetTo(view: navigationStack(rootView: view))
            } else {
                Color.white.opacity(0.01)
                    .environment(\.coordinator, nil)
            }
        }
    }
    
    @ViewBuilder
    private func addSheetTo(view: (some View)?) -> some View {
        let router = coordinator.router
        
        view.environment(\.coordinator, coordinator)
            .sheetCoordinator(
            coordinator: router.sheetCoordinator,
            onDissmis: { index in Task(priority: .high) { [weak router] in
                await router?.removeItemFromSheetCoordinator(at: index)
            }},
            onDidLoad: nil
        )
    }
    
    @ViewBuilder
    private func navigationStack(rootView: (some View)?) -> some View {
        let router = coordinator.router
        NavigationStack(
            path: Binding(get: { router.items }, set: { router.items = $0 }),
            root: { rootView?.navigationDestination(for: C.Route.self) { $0 } }
        )
        .transaction { $0.disablesAnimations = !router.animated }
        .onChange(of: router.items) { _, _ in onChangeItems() }
    }
    
    // --------------------------------------------------------------------
    // MARK: Helper functions
    // --------------------------------------------------------------------
    
    private func onChangeItems() {
        Task { await viewModel.syncItems() }
    }
}
