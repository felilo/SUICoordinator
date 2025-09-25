//
//  NavigationActionListDetailViewModel.swift
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

class NavigationActionListDetailViewModel: ObservableObject {
    
    var coordinator: HomeCoordinator
    var title: String
    
    init(coordinator: HomeCoordinator, title: String) {
        self.coordinator = coordinator
        self.title = title
    }
    
    @MainActor func presentSheet() async {
        await coordinator.presentSheet()
    }
    
    @MainActor func presentFullscreen() async {
        await coordinator.presentFullscreen()
    }
    
    @MainActor func presentViewWithCustomPresentation() async {
        await coordinator.presentViewWithCustomPresentation()
    }
    
    @MainActor func presentDetentsView() async {
        await coordinator.presentDetents()
    }
    
    @MainActor func navigateToPushView() async {
        await coordinator.navigateToPushView()
    }
    
    @MainActor func close() async {
        await coordinator.close()
    }
    
    @MainActor func finish() async {
        await coordinator.finish()
    }
    
    @MainActor func restartCoordinator() async {
        await coordinator.restart()
    }
    
    @MainActor func presentCustomTabCoordinator() async {
        await coordinator.presentCustomTabCoordinator()
    }
}