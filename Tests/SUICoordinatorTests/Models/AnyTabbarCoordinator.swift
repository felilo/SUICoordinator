//
//  File.swift
//  
//
//  Created by Andres Lozano on 21/01/24.
//

import SwiftUI
@testable import SUICoordinator


class AnyTabbarCoordinator: TabbarCoordinator<AnyEnumTabbarRoute> {
    init(currentPage: AnyEnumTabbarRoute = .tab1) {
        super.init(pages: PAGE.sortedByPosition(), currentPage: currentPage)
    }
}


enum AnyEnumTabbarRoute: TabbarPage, CaseIterable {
    case tab1
    case tab2
    
    
    @ViewBuilder
    public var icon: (any View) {
        switch self {
            case .tab1: Image.init(systemName: "homekit")
            case .tab2: Image.init(systemName: "gear")
        }
    }
    
    @ViewBuilder
    public var title: (any View) {
        switch self {
            case .tab1: Text("Tab1")
            case .tab2: Text("Tab2")
        }
    }
    
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
