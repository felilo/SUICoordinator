//
//  HomeCoordinator.swift
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

import SUICoordinator
import Foundation

class HomeCoordinator: Coordinator<HomeRoute> {
    
    private let animated: Bool  = true
    
    // ---------------------------------------------------------------------
    // MARK: Coordinator
    // ---------------------------------------------------------------------
    
    override func start(animated: Bool = true) async {
        let viewModel = ActionListViewModel(coordinator: self)
        await startFlow(route: .actionListView(viewModel: viewModel), animated: animated)
    }
    
    // ---------------------------------------------------------------------
    // MARK: Aditional flows
    // ---------------------------------------------------------------------
    
    func navigateToPushView(index: Int) async {
        let viewModel = PushViewModel(coordinator: self, index: index)
        await router.navigate(toRoute: .push(viewModel: viewModel), animated: animated)
    }
    
    func presentSheet() async {
        let viewModel = SheetViewModel(coordinator: self)
        await router.navigate(toRoute: .sheet(viewModel: viewModel), animated: animated)
    }
    
    func presentFullscreen() async {
        let viewModel = FullscreenViewModel(coordinator: self)
        await router.navigate(toRoute: .fullscreen(viewModel: viewModel), animated: animated)
    }
    
    func presentDetents() async {
        let viewModel = DetentsViewModel(coordinator: self)
        await router.navigate(toRoute: .detents(viewModel: viewModel), animated: animated)
    }
    
    func presentTabbarCoordinator() async {
        let coordinator = CustomTabbarCoordinator()
        await navigate(to: coordinator, presentationStyle: .sheet, animated: animated)
    }
    
    func close() async {
        await router.close(animated: animated)
    }
    
    func finish() async {
        await finishFlow(animated: animated)
    }
}
