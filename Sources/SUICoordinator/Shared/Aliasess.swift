//
//  Aliasess.swift
//  SUICoordinator
//
//  Created by Andres Lozano on 23/05/25.
//

import SwiftUI
// Re-export all core types so consumers of SUICoordinator don't need to import SUICoordinatorCore.
@_exported import SUICoordinatorCore

@available(iOS 17.0, *)
public typealias AnyCoordinatorType = (any CoordinatorType)
