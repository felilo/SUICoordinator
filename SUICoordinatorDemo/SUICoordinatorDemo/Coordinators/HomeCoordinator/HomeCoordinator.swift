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
    
    // ---------------------------------------------------------------------
    // MARK: Coordinator
    // ---------------------------------------------------------------------
    
    override func start(animated: Bool = true, completion: (() -> Void)? = nil) {
        let viewModel = ActionListViewModel(coordinator: self)
        startFlow(route: .actionListView(viewModel: viewModel), completion: completion)
    }
    
    // ---------------------------------------------------------------------
    // MARK: Adiotional flows
    // ---------------------------------------------------------------------
    
    func navigateToPushView() {
        let viewModel = PushViewModel(coordinator: self)
        router.navigate(to: .push(viewModel: viewModel))
    }
    
    func presentSheet() {
        let viewModel = SheetViewModel(coordinator: self)
        router.navigate(to: .sheet(viewModel: viewModel))
    }
    
    func presentFullscreen() {
        let viewModel = FullscreenViewModel(coordinator: self)
        router.navigate(to: .fullscreen(viewModel: viewModel))
    }
    
    func presentDetents() {
        let viewModel = DetentsViewModel(coordinator: self)
        router.navigate(to: .detents(viewModel: viewModel))
    }
    
    func presentTabbarCoordinator() {
        let coordinator = TabbarFlowCoordinator()
        navigate(to: coordinator, presentationStyle: .sheet)
    }
    
    func close() {
        router.close(completion: nil)
    }
    
    func finsh() {
        finishFlow(animated: true, completion: nil)
    }
}
