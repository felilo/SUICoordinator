//
//  File.swift
//  
//
//  Created by Andres Lozano on 19/01/24.
//

import SwiftUI
@testable import SUICoordinator

class AnyCoordinator: Coordinator<AnyEnumRoute> {
    override func start(animated: Bool = true, completion: Completion? = nil) {
        startFlow(route: .pushStep, completion: completion)
    }
}

class OtherCoordinator: Coordinator<AnyStructRoute> {
    override func start(animated: Bool = true, completion: Completion? = nil) {
        startFlow(route: .init(presentationStyle: .detents([.medium])), completion: completion)
    }
}
