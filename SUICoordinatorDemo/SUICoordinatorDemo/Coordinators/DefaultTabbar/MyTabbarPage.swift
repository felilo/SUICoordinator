//
//  DefaultTabbarPage.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SUICoordinator
import SwiftUI


public enum MyTabbarPage: TabbarPage, CaseIterable {
    
    case first
    case second
    
    // ---------------------------------------------------------
    // MARK: TabbarPage
    // ---------------------------------------------------------
    
    public var badge: String? {
        switch self {
            case .first: "new"
            case .second: "10"
        }
    }
    
    @ViewBuilder
    public var icon: (any View) {
        switch self {
            case .first: Image.init(systemName: "homekit")
            case .second: Image.init(systemName: "gear")
        }
    }
    
    @ViewBuilder
    public var title: (any View) {
        switch self {
            case .first: Text("first")
            case .second: Text("second")
        }
    }
    
    public var position: Int {
        switch self {
            case .first: return 0
            case .second: return 1
        }
    }
    
    public func coordinator() -> (any CoordinatorType) {
        switch self {
            case .first:
                return HomeCoordinator()
            case .second:
                return TabbarFlowCoordinator()
        }
    }
}
