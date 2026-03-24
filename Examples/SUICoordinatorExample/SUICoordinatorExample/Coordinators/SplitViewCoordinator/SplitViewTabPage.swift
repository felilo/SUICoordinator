//
//  SplitViewTabPage.swift
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

/// Pages shown in the sidebar of the `NavigationSplitView` example.
public enum SplitViewTabPage: TabPage, CaseIterable {
    
    case home
    case hub
    
    // ---------------------------------------------------------
    // MARK: TabPage
    // ---------------------------------------------------------
    
    public var position: Int {
        switch self {
        case .home: return 0
        case .hub:  return 1
        }
    }
    
    public func coordinator() -> AnyCoordinatorType {
        switch self {
        case .home: return HomeCoordinator()
        case .hub:  return NavigationHubCoordinator()
        }
    }
    
    public var dataSource: SplitViewTabPageDataSource {
        .init(page: self)
    }
}

// ---------------------------------------------------------
// MARK: SplitViewTabPageDataSource
// ---------------------------------------------------------

public struct SplitViewTabPageDataSource {
    
    let page: SplitViewTabPage
    
    @ViewBuilder
    public var icon: some View {
        switch page {
        case .home: Image(systemName: "house.fill")
        case .hub:  Image(systemName: "network")
        }
    }
    
    @ViewBuilder
    public var title: some View {
        switch page {
        case .home: Text("Home")
        case .hub:  Text("Hub")
        }
    }
}
