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

import Foundation
import SUICoordinator

enum HomeRoute: RouteType {
    
    case push(viewModel: PushViewModel)
    case sheet(viewModel: SheetViewModel)
    case fullscreen(viewModel: FullscreenViewModel)
    case detents(viewModel: DetentsViewModel)
    case actionListView(viewModel: ActionListViewModel)
    case viewCustomTransition(viewModel: PushViewModel)
    
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
    
    
    var view: Body {
        switch self {
        case .push(let viewModel), .viewCustomTransition(let viewModel):
                PushView(viewModel: viewModel)
            case .sheet(let viewModel):
                SheetView(viewModel: viewModel)
            case .fullscreen(let viewModel):
                FullscreenView(viewModel: viewModel)
            case .detents(let viewModel):
                DetentsView(viewModel: viewModel)
            case .actionListView(let viewModel):
                NavigationActionListView(viewModel: viewModel)
        }
    }
}
