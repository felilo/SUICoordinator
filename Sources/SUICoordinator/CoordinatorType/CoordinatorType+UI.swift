//
//  CoordinatorType+UI.swift
//  SUICoordinator
//
//  Created by Andres Lozano on 11/12/24.
//

import SwiftUI

public extension CoordinatorType {
    
    @ViewBuilder
    func getView() -> some View {
        CoordinatorView(dataSource: self)
    }
}
