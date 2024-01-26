//
//  ViewDidLoadModifier.swift
//  CRNavigation
//
//  Created by Andres Lozano on 26/12/23.
//

import SwiftUI

public extension View {
	
	func sheetCoordinating(
		coordinator: SheetCoordinator<(any View)>,
		index: Int = 0,
		isLast: Bool = false,
		onDissmis: ((Int) -> Void)? = nil,
		onDidLoad: ((Int) -> Void)? = nil
	) -> some View {
		modifier(
			SheetCoordinating(
				coordinator: coordinator,
				index: index,
				isLast: isLast,
				onDissmis: onDissmis,
				onDidLoad: onDidLoad
			)
		)
	}
	
	func onViewDidLoad(perform action: (() -> Void)? = nil) -> some View {
		self.modifier(ViewDidLoadModifier(action: action))
	}
}
