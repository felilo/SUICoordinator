//
//  TabFlowCoordinator.swift
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

@Coordinator(DefaultRoute.self)
class NavigationHubCoordinator {

    init() {}

    // ---------------------------------------------------------------------
    // MARK: CoordinatorType
    // ---------------------------------------------------------------------

    func start() async {
        let _self = self
        let route = DefaultRoute(
            presentationStyle: .push,
            content: {
                CoordinatorActionListView()
                    .environment(\.navigationHubCoordinator, _self)
            }
        )

        await startFlow(route: route)
    }

    func finish() async {
        await finishFlow(animated: true)
    }
}


extension NavigationHubCoordinator: ActionListCoordinatorType {
    
    // ---------------------------------------------------------------------
    // MARK: ActionListCoordinatorType
    // ---------------------------------------------------------------------

    func navigateToPushView() async {
        await presentHomeCoordinatorWithCustomNavigation()
    }

    func presentSheet() async {
        await presentHomeCoordinator()
    }

    func presentFullscreen() async {
        await presentDefaultTabCoordinator()
    }

    func presentDetents() async {
        let coordinator = HomeCoordinator(config: .init(initialRoute: .detents(title: "Hello, Detents!")))
        await navigate(to: coordinator, presentationStyle: .detents([.medium]))
    }

    func presentViewWithCustomPresentation() async {
        await presentCustomTabCoordinator()
    }

    func close() async {
        await close(animated: true)
    }

    func restart() async {
        await restart(animated: true)
    }
}

extension NavigationHubCoordinator: NavigationHubCoordinatorType {
    func presentDefaultTabCoordinator() async {
        let coordinator = DefaultTabCoordinator()
        await navigate(to: coordinator, presentationStyle: .fullScreenCover)
    }

    func presentCustomTabCoordinator() async {
        let coordinator = CustomTabCoordinator()
        await navigate(to: coordinator, presentationStyle: .sheet)
    }

    func presentSplitViewCoordinator() async {
        let coordinator = SplitViewCoordinator()
        await navigate(to: coordinator, presentationStyle: .fullScreenCover)
    }

    func presentHomeCoordinator() async {
        let coordinator = HomeCoordinator()
        await navigate(to: coordinator, presentationStyle: .detents([.medium, .large]))
    }

    func presentHomeCoordinatorWithCustomNavigation() async {
        let coordinator = NavigationHubCoordinator()
        await navigate(to: coordinator, presentationStyle: .push)
    }

    func presentNavigationActionList() async {
        let _self = self
        let route = DefaultRoute(
            presentationStyle: .push,
            content: {
                NavigationActionListView()
                    .environment(\.actionListCoordinator, _self)
            }
        )
        await navigate(toRoute: route)
    }
}
