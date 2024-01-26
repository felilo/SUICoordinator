//
//  FirstView.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SwiftUI

struct DetentsView: View {
    
    typealias ViewModel = DetentsViewModel
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            VStack {
                Text("Hello, DetentsView!")
                    .font(.largeTitle)
                
                VStack {
                    Button("Presents Tabbar Coordinator") {
                        viewModel.navigateToNextView()
                    }.buttonStyle(.borderedProminent)
                    
                    Button("Close view") {
                        viewModel.close()
                    }.buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

#Preview {
    DetentsView(viewModel: .init(coordinator: .init()))
}
