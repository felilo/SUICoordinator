//
//  SheetView.swift
//  CRNavigation
//
//  Created by Andres Lozano on 19/12/23.
//

import SwiftUI

struct SheetView<Content: View, T: SCIdentifiable>: View {
	
	typealias Item = T
	
	// ---------------------------------------------------------
	// MARK: Wrapper properties
	// ---------------------------------------------------------
	
	@Binding var items: [Item?]
	
	// ---------------------------------------------------------
	// MARK: Properties
	// ---------------------------------------------------------
	
	let index: Int
	let content: ( (Int, (Item)) -> Content)
	let onDismiss: ((Int) -> Void)?
	let onDidLoad: ((Int) -> Void)?
	let transitionStyle: TransitionPresentationStyle?
	
	// ---------------------------------------------------------
	// MARK: Constructor
	// ---------------------------------------------------------
	
	init(
		index: Int,
		items: Binding<[Item?]>,
		@ViewBuilder content: @escaping (Int, (Item)) -> Content,
		transitionStyle: TransitionPresentationStyle?,
		onDismiss: ((Int) -> Void)? = nil,
		onDidLoad: ((Int) -> Void)?
	) {
		self.index = index
		self._items = items
		self.content = content
		self.onDismiss = onDismiss
		self.onDidLoad = onDidLoad
		self.transitionStyle = transitionStyle
	}
	
	// ---------------------------------------------------------
	// MARK: View
	// ---------------------------------------------------------
	
	var body: some View {
		ForEach($items.indices, id: \.self) { (index) in
			if index == self.index {
				let item = $items[index]
				switch transitionStyle {
					case .fullScreenCover:
						fullScreenView(item: item)
					default: sheetView(item: item)
				}
			}
		}
	}
	
	// ---------------------------------------------------------
	// MARK: Helper Views
	// ---------------------------------------------------------
	
	@ViewBuilder
	private func sheetView(item: Binding<Item?>) -> some View {
		Color.clear.frame(width: 0.3, height: 0.3)
			.sheet(
				item: item,
				onDismiss: { onDismiss?(index) },
				content: { content(index, $0) }
			).onAppear { onDidLoad?(index) }
	}
	
	@ViewBuilder
	private func fullScreenView(item: Binding<Item?>) -> some View {
		Color.clear.frame(width: 0.3, height: 0.3)
			.fullScreenCover(
				item: item,
				onDismiss: { onDismiss?(index) },
				content: { content(index, $0) }
			).onAppear{ onDidLoad?(index)}
	}
}
