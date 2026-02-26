//
//  Aliasess.swift
//  SUICoordinator
//
//  Created by Andres Lozano on 23/05/25.
//

import SwiftUI

public typealias ActionClosure = (String) -> Void
// AnyCoordinatorType is defined in each platform layer because it depends on
// CoordinatorType, which differs between SUICoordinator (iOS 17+) and SUICoordinator16.
public typealias AnyViewAlias = (any View)
