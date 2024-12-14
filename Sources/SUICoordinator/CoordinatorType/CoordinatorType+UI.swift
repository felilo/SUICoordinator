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
        if let viewModel = self as? Coordinator<Route> {
            CoordinatorView<Route>(viewModel: viewModel)
        }
    }
}
