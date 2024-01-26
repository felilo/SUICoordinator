//
//  TabbarFlowCoordinator.swift
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

class TabbarFlowCoordinator: Coordinator<RouteBase> {
    
    // ---------------------------------------------------------------------
    // MARK: Coordinator
    // ---------------------------------------------------------------------
    
    override func start(animated: Bool = true, completion: Completion? = nil) {
        let viewModel = TabbarActionListViewModel(coordinator: self)
        
        let route = RouteBase(
            presentationStyle: .push,
            content: TabbarActionListView(viewModel: viewModel)
        )
        
        startFlow(route: route )
    }
    
    // ---------------------------------------------------------------------
    // MARK: Adiotional flows
    // ---------------------------------------------------------------------
    
    func presentDefaultTabbarCoordinator() {
        let coordinator = DefaultTabbarCoordinator()
        navigate(to: coordinator, presentationStyle: .fullScreenCover)
    }
    
    func presentCustomTabbarCoordinator() {
        let coordinator = CustomTabbarCoordinator()
        navigate(to: coordinator, presentationStyle: .sheet)
    }
    
    func close() {
        router.close(completion: nil)
    }
    
    func finish() {
        finishFlow(animated: true, completion: nil)
    }
}
