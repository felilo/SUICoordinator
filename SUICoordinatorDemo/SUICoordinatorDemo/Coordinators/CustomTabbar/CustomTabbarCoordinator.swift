//
//  CustomTabbarCoordinator.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import Foundation
import Combine
import SUICoordinator

public class CustomTabbarCoordinator: TabbarCoordinator<MyTabbarPage> {
    
    private var cancelables = Set<AnyCancellable>()
    let viewModel: CustomTabbarViewModel
    
    
    public init(
        currentPage: MyTabbarPage = .first,
        presentationStyle: TransitionPresentationStyle = .sheet
    ) {
        
        viewModel = CustomTabbarViewModel()
        viewModel.currentPage = currentPage
        
        super.init(
            pages: PAGE.allCases,
            currentPage: currentPage,
            customView: CustomTabbarView(viewModel: viewModel)
        )
        
        setupObservers()
    }
    
    
    private func setupObservers() {
        viewModel.$currentPage
              .sink { [weak self] page in
                self?.currentPage = page
              }.store(in: &cancelables)
        
        viewModel.getCoordinator = { [weak self] positon in
            self?.getCoordinator(with: positon)
        }
    }
}


