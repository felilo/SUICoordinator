//
//  HomeRoute.swift
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
import SUICoordinator

enum HomeRoute: RouteType {
    
    case push(coordinator: HomeCoordinator, title: String)
    case sheet(coordinator: HomeCoordinator, title: String)
    case fullscreen(coordinator: HomeCoordinator, title: String)
    case detents(coordinator: HomeCoordinator, title: String)
    case actionListView
    case viewCustomTransition(coordinator: HomeCoordinator, title: String)
    
    // ---------------------------------------------------------------------
    // MARK: RouteType
    // ---------------------------------------------------------------------
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
        case .push:
            return .push
        case .sheet:
            return .sheet
        case .fullscreen:
            return .fullScreenCover
        case .detents:
            return .detents([.medium])
        case .actionListView:
            return .push
        case .viewCustomTransition:
            return .custom(
                transition: .move(edge: .leading),
                animation: .bouncy,
            )
        }
    }
    
    
    var body: some View {
        switch self {
        case let .push(coordinator, title),
            let .viewCustomTransition(coordinator, title),
            let .sheet(coordinator, title),
            let .fullscreen(coordinator, title),
            let .detents(coordinator, title):
            NavigationActionListDetailView(coordinator: coordinator, title: title)
        case .actionListView:
            NavigationActionListView()
        }
    }
}
