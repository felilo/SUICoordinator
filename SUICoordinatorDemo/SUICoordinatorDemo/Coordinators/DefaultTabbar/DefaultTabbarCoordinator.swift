//
//  DefaultTabbar.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import Foundation
import SUICoordinator

class DefaultTabbarCoordinator: TabbarCoordinator<MyTabbarPage> {
    
    init() {
        super.init(pages: PAGE.allCases, currentPage: .second)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.setBadge.send(( "2", .first ))
        }
    }
}



