//
//  CustomTabbarViewModel.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import Foundation
import SUICoordinator

class CustomTabbarViewModel: ObservableObject {
    
    
    typealias Route = MyTabbarPage
    
    // ---------------------------------------------------------------------
    // MARK: Published
    // ---------------------------------------------------------------------
    
    @Published var currentPage: Route =  .first
    var getCoordinator: ((Int) -> (any CoordinatorType)?)?
    
    // ---------------------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------------------
    
    var pages = Route.allCases
    
    // ---------------------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------------------
    
    func setCurrentPage(_ value: Route) {
        guard value != currentPage else { return }
        currentPage = value
    }
}


