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

import Foundation
import SUICoordinator

@Coordinator(HomeRoute.self)
class HomeCoordinator {
    
    @ObservationIgnored
    private let config: HomeCoordinatorConfig
    
    // ---------------------------------------------------------------------
    // MARK: Init
    // ---------------------------------------------------------------------
    
    init(config: HomeCoordinatorConfig = .init()) {
        self.config = config
    }
    
    // ---------------------------------------------------------------------
    // MARK: CoordinatorType
    // ---------------------------------------------------------------------
    
    func start() async {
        let route: HomeRoute = switch config.initialRoute {
        case let .detents(title):
                .detents(coordinator: self, title: title)
        default:
                .actionListView
        }
        await startFlow(route: route)
    }
}

extension HomeCoordinator: ActionListCoordinatorType {
    
    func navigateToPushView() async {
        let title = "Hello, PushView!"
        await navigate(toRoute: .push(coordinator: self, title: title), animated: config.animated)
    }
    
    func presentSheet() async {
        let title = "Hello, Sheet!"
        await navigate(toRoute: .sheet(coordinator: self, title: title), animated: config.animated)
    }
    
    func presentFullscreen() async {
        let title = "Hello, Fullscreen!"
        await navigate(toRoute: .fullscreen(coordinator: self, title: title), animated: config.animated)
    }
    
    func presentDetents() async {
        let title = "Hello, Detents!"
        await navigate(toRoute: .detents(coordinator: self, title: title), animated: config.animated)
    }
    
    func presentViewWithCustomPresentation() async {
        let title = "Hello, Custom presentation!"
        await navigate(toRoute: .viewCustomTransition(coordinator: self, title: title), animated: config.animated)
    }
    
    func presentCustomTabCoordinator() async {
        let coordinator = CustomTabCoordinator()
        await navigate(to: coordinator, presentationStyle: .sheet, animated: config.animated)
    }
    
    func finish() async {
        await finishFlow(animated: config.animated)
    }
    
    func close() async {
        await close(animated: config.animated)
    }
    
    func restart() async {
        await restart(animated: config.animated)
    }
}

// ---------------------------------------------------------------------
// MARK: HomeCoordinatorConfig
// ---------------------------------------------------------------------

struct HomeCoordinatorConfig {
    var initialRoute: InitialRoute?
    var animated: Bool = true
    
    enum InitialRoute {
        case detents(title: String)
    }
}
