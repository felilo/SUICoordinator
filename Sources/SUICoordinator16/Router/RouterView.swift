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
    private let coordinator: C
    
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
    }
    
    // --------------------------------------------------------------------
    // MARK: View helper functions
    // --------------------------------------------------------------------
    
    @ViewBuilder
    private func buildBody() -> some View {
        Group {
            if let view = viewModel.mainView {
                if coordinator.isTabCoordinable == true {
                    view.environment(\.coordinator, nil)
                } else {
                    addSheetTo(view: navigationStack(rootView: view))
                }
            } else {
                Color.white.opacity(0.01)
                    .environment(\.coordinator, nil)
            }
        }
    }
    
    @ViewBuilder
    private func addSheetTo(view: (some View)?) -> some View {
        let router = viewModel
        view.environment(\.coordinator, coordinator)
            .sheetCoordinator(
            coordinator: viewModel.sheetCoordinator,
            coordinatorType: coordinator,
            onDissmis: { index in Task { @MainActor [weak router] in
                guard let router else { return }
                if !router.isCoordinator {
                    await router.removeItemFromSheetCoordinator(at: index)
                }
            }},
            onDisappear: { index in Task { @MainActor [weak router] in
                guard let router else { return }
                if router.isCoordinator {
                    await router.onFinish.send(())
                    await router.removeItemFromSheetCoordinator(at: index)
                }
            }}
        )
    }
    
    @ViewBuilder
    private func navigationStack(rootView: (some View)?) -> some View {
        let router = viewModel
        NavigationStack(
            path: Binding(get: { router.items }, set: { router.items = $0 }),
            root: { rootView?.navigationDestination(for: C.Route.self) { $0 } }
        )
        .transaction { $0.disablesAnimations = !router.animated }
        .onChange(of: viewModel.items, perform: { _ in onChangeItems() })
    }
    
    // --------------------------------------------------------------------
    // MARK: Helper functions
    // --------------------------------------------------------------------
    
    private func onChangeItems() {
        Task { await viewModel.syncItems() }
    }
}

private struct CoordinatorKey: EnvironmentKey {
    static var defaultValue: AnyCoordinatorType? { nil }
}

public extension EnvironmentValues {
    var coordinator: AnyCoordinatorType? {
        get { self[CoordinatorKey.self] }
        set { self[CoordinatorKey.self] = newValue }
    }
}
