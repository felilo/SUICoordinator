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
            CoordinatorView<Route>(
                viewModel: viewModel,
                onClean: { await self.clean() },
                onSetTag: { tag in self.tagId = tag }
            )
        }
    }
    
    private func clean() async {
        guard !isEmptyCoordinator else {
            return
        }
        await finish(animated: false, withDismiss: false)
    }
}
