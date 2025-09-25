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
    
    override func start() async {
        await startFlow(route: .actionListView)
    }
    
    // ---------------------------------------------------------------------
    // MARK: Additional flows
    // ---------------------------------------------------------------------
    
    func navigateToPushView() async {
        let title = "Hello, PushView! \(router.items.count + 1)"
        await navigate(toRoute: .push(coordinator: self, title: title), animated: animated)
    }
    
    func presentSheet() async {
        let title = "Hello, Sheet! \(router.items.count + 1)"
        await navigate(toRoute: .sheet(coordinator: self, title: title), animated: animated)
    }
    
    func presentFullscreen() async {
        let title = "Hello, Fullscreen! \(router.items.count + 1)"
        await navigate(toRoute: .fullscreen(coordinator: self, title: title), animated: animated)
    }
    
    func presentDetents() async {
        let title = "Hello, Detents! \(router.items.count + 1)"
        await navigate(toRoute: .detents(coordinator: self, title: title), animated: animated)
    }
    
    func presentViewWithCustomPresentation() async {
        let title = "Hello, Custom presentation! \(router.items.count + 1)"
        await navigate(toRoute: .viewCustomTransition(coordinator: self, title: title), animated: animated)
    }
    
    func presentCustomTabCoordinator() async {
        let coordinator = CustomTabCoordinator()
        await navigate(to: coordinator, presentationStyle: .sheet, animated: animated)
    }
    
    func finish() async {
        await finishFlow(animated: animated)
    }
}
