//
//  FirstView.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SwiftUI

struct FullscreenView: View {
    
    typealias ViewModel = FullscreenViewModel
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            VStack {
                Text("Hello, FullscreenView!")
                    .font(.largeTitle)
                
                VStack {
                    Button("Presents DetentsView") {
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
    FullscreenView(viewModel: .init(coordinator: .init()))
}
