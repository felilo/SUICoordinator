//
//  FirstView.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SwiftUI

struct SheetView: View {
    
    typealias ViewModel = SheetViewModel
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            VStack {
                Text("Hello, SheetView!")
                    .font(.largeTitle)
                
                VStack {
                    Button("Presents FullscreenView") {
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
    SheetView(viewModel: .init(coordinator: .init()))
}
