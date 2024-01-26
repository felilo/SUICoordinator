//
//  SheetCoordinating.swift
//  UserInterfaz
//
//  Created by Andres Lozano on 28/11/23.
//

import SwiftUI
import Combine

struct SheetCoordinating: ViewModifier {
	
	// ---------------------------------------------------------
	// MARK: typealias
	// ---------------------------------------------------------
	
	typealias Action = ((Int) -> Void)
	typealias Value = (any View)
	
	// ---------------------------------------------------------
	// MARK: Wrapper Properties
	// ---------------------------------------------------------
	
	@StateObject var coordinator: SheetCoordinator<Value>
	@State var index = 0
	
	// ---------------------------------------------------------
	// MARK: Properties
	// ---------------------------------------------------------
	
	public var isLast: Bool
	public var onDissmis: Action?
	public var onDidLoad: Action?
	
	// ---------------------------------------------------------
	// MARK: ViewModifier
	// ---------------------------------------------------------
	
	@ViewBuilder
	func body(content: Content) -> some View {
		content
			.background {
				if $coordinator.items.isEmpty || isLast {
					EmptyView()
				} else {
					SheetView(
						index: index,
						items: $coordinator.items,
						content: { (index, item) in
							let view = AnyView(item.view)
								.sheetCoordinating(
									coordinator: coordinator,
									index: (index + 1),
									isLast: index == coordinator.totalItems,
									onDissmis: onDissmis,
									onDidLoad: onDidLoad
								)
							
							buildContent(
								transitionStyle: item.presentationStyle,
								content: view
							)
						},
						transitionStyle: coordinator.lastPresentationStyle,
						onDismiss: onDissmis,
						onDidLoad: onDidLoad
					)
				}
			}
	}
	
	// ---------------------------------------------------------
	// MARK: Helper Views
	// ---------------------------------------------------------
	
	@ViewBuilder
	private func buildContent(
		transitionStyle: TransitionPresentationStyle?,
		content: some View
	) -> some View {
		switch transitionStyle {
			case .detents(let data): content.presentationDetents(data)
			default: content
		}
	}
}
