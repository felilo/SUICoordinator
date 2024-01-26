//
//  CoordinatorView.swift
//  Navigation
//
//  Created by Andres Lozano on 30/11/23.
//

import SwiftUI


public struct CoordinatorView<Route: RouteType>: CoordinatorViewType, View {
	
	// --------------------------------------------------------------------
	// MARK: Wrapper properties
	// --------------------------------------------------------------------
	
	@StateObject var viewModel: Coordinator<Route>
	
	// --------------------------------------------------------------------
	// MARK: Properties
	// --------------------------------------------------------------------
	
	var onClean: (() -> Void)?
	var onSetTag: ((String) -> Void)?
	
	// --------------------------------------------------------------------
	// MARK: Constructor
	// --------------------------------------------------------------------
	
	init(
		viewModel: Coordinator<Route>,
		onClean: (() -> Void)? = nil,
		onSetTag: ((String) -> Void)? = nil
	) {
		self._viewModel = .init(wrappedValue: viewModel)
		self.onClean = onClean
		self.onSetTag = onSetTag
	}
	
	// --------------------------------------------------------------------
	// MARK: View
	// --------------------------------------------------------------------
	
	public var body: some View {
		NavigationRouterView(viewModel: viewModel.router)
			.onViewDidLoad { [weak viewModel] in viewModel?.start() }
	}
	
	// --------------------------------------------------------------------
	// MARK: CoordinatorViewType
	// --------------------------------------------------------------------
	
	func clean() { onClean?() }
}
