//
//  FirstView.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SwiftUI

struct ActionListView: View {
    
    typealias ViewModel = ActionListViewModel
    
    @Environment(\.isPresented) private var isPresented
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        List {
            Button("Push NavigationView") {
                viewModel.navigateToFirstView()
            }
            
            Button("Presents SheetView") {
                viewModel.presentSheet()
            }
            
            Button("Presents FullscreenView") {
                viewModel.presentFullscreen()
            }
            
            Button("Presents DetentsView") {
                viewModel.presentDetents()
            }
            
            Button("Presents Tabbar Coordinator") {
                viewModel.presentTabbarCoordinator()
            }
        }
        .toolbar {
            if isPresented && viewModel.showFinishButton() {
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
