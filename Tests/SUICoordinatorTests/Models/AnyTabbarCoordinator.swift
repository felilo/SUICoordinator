//
//  AnyTabCoordinator.swift
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
@testable import SUICoordinator


class AnyTabCoordinator: TabCoordinator<AnyEnumTabRoute> {
    init(currentPage: AnyEnumTabRoute = .tab1) {
        super.init(
            pages: Page.sortedByPosition(),
            currentPage: currentPage,
            viewContainer: { AnyTabView(dataSource: $0) }
        )
    }
}


enum AnyEnumTabRoute: TabPage, CaseIterable {
    case tab1
    case tab2
    
    
    var dataSource: AnyTabDataSource { .init()  }
    
    public var position: Int {
        switch self {
            case .tab1: return 0
            case .tab2: return 1
        }
    }
    
    public func coordinator() -> (any CoordinatorType) {
        switch self {
            case .tab1:
                return AnyCoordinator()
            case .tab2:
                return OtherCoordinator()
        }
    }
}

struct AnyTabDataSource { }

struct AnyTabView<DataSource: TabCoordinatorType>: View where DataSource.DataSourcePage == AnyTabDataSource {
    let dataSource: DataSource
    
    var body: some View { EmptyView() }
}
