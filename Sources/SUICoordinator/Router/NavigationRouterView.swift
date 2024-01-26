//
//  RouterView.swift
//  CRNavigation
//
//  Created by Andres Lozano on 4/12/23.
//

import SwiftUI
import Combine

struct NavigationRouterView<Router: RouterType>: View {
	
	// --------------------------------------------------------------------
	// MARK: Properties
	// --------------------------------------------------------------------
	
	@StateObject var viewModel: Router
	@State private var firstView: AnyView = AnyView(Text("Loading"))
	
	// --------------------------------------------------------------------
	// MARK: Constructor
	// --------------------------------------------------------------------
	
	public init(viewModel: Router) {
		self._viewModel = .init(wrappedValue: viewModel)
	}
	
	// --------------------------------------------------------------------
	// MARK: View
	// --------------------------------------------------------------------
	
	var body: some View {
		
		if viewModel.coordinator?.isTabbarCoordinable == true {
			addSheetTo(view: firstView)
		} else {
			let view = NavigationStack(path: $viewModel.items) {
				firstView.navigationDestination(for: Router.Route.self) {
					AnyView($0.view)
				}
			}
			addSheetTo(view: view)
		}
	}
	
	// --------------------------------------------------------------------
	// MARK: Helper funcs
	// --------------------------------------------------------------------
	
	@ViewBuilder
	private func addSheetTo(view: some View ) -> some View {
		view
			.onChange(of: viewModel.mainView, perform: onChangeFirstView)
			.sheetCoordinating(
				coordinator: viewModel.sheetCoordinator,
				onDissmis: { [weak viewModel] index in
					viewModel?.sheetCoordinator.remove(at: index)
				},
				onDidLoad: nil
			)
	}
	
	private func onChangeFirstView(_ value: Router.Route?)  {
		guard let view = value?.view else { return }
		firstView = AnyView(view)
	}
}
