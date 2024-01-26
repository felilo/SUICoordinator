//
//  TabbarCoordinatorView.swift
//  CRNavigation
//
//  Created by Andres Lozano on 23/12/23.
//

import SwiftUI
import Foundation

struct TabbarCoordinatorView<PAGE: TabbarPage>: View {
	
	typealias BadgeItem = (value: String?, page: PAGE)
	
	// ---------------------------------------------------------------------
	// MARK: Properties
	// ---------------------------------------------------------------------
	
	@StateObject var viewModel: TabbarCoordinator<PAGE>
	@State var badges = [BadgeItem]()
	
	// ---------------------------------------------------------------------
	// MARK: View
	// ---------------------------------------------------------------------
	
	var body: some View {
		TabView(selection: tabSelection()){
			ForEach(viewModel.pages, id: \.self, content: makeTabView)
		}
		.onReceive(viewModel.$pages) { pages in
			badges = pages.map { (nil, $0) }
		}
		.onReceive(viewModel.setBadge) { (value, page) in
			guard let index = getBadgeIndex(page: page) else { return }
			badges[index].value = value
		}
	}
	
	// ---------------------------------------------------------------------
	// MARK: Helper funcs
	// ---------------------------------------------------------------------
	
	@ViewBuilder
	func makeTabView(page: PAGE) -> some View {
		if let item = viewModel.getCoordinator(with: page.position) {
			AnyView( item.view )
				.tabItem {
					Label(
						title: { AnyView(page.title) },
						icon: { AnyView(page.icon) } )
				}
                .badge(getBadge(page: page)?.value)
				.tag(page)
		}
	}
	
	private func getBadge(page: PAGE) -> BadgeItem? {
		guard let index = getBadgeIndex(page: page) else {
			return nil
		}
		return badges[index]
	}
	
	private func getBadgeIndex(page: PAGE) -> Int? {
		badges.firstIndex(where: { $0.1 == page })
	}
}


extension TabbarCoordinatorView {
	
	private func tabSelection() -> Binding<PAGE> {
		Binding {
			self.viewModel.currentPage
		} set: { tappedTab in
			if tappedTab == self.viewModel.currentPage {
				try? viewModel.getCoordinatorSelected().root.popToRoot(animated: true, completion: nil)
			}
			self.viewModel.currentPage = tappedTab
		}
	}
}
