//
//  FirstView.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SwiftUI

struct TabbarActionListView: View {
    
    typealias ViewModel = TabbarActionListViewModel
    
    
    @Environment(\.isPresented) private var isPresented
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        List {
            
            Button("Presents Default Tabbar") {
                viewModel.presentDefaultTabbarCoordinator()
            }
            
            Button("Presents Custom Tabbar") {
                viewModel.presentCustomTabbarCoordinator()
            }
        }
        .toolbar {
            if isPresented {
                Button {
                    viewModel.finsh()
                } label: {
                    Text("Finish flow")
                }
            }
        }
        .navigationTitle("Navigation List")
    }
}

#Preview {
    ActionListView(viewModel: .init(coordinator: .init()))
}
