//
//  FirstView.swift
//  SUICoordinatorDemo
//
//  Created by Andres Lozano on 24/01/24.
//

import SwiftUI

struct PushView: View {
    
    typealias ViewModel = PushViewModel
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            VStack {
                Text("Hello, PushView!")
                    .font(.largeTitle)
                
                VStack {
                    Button("Presents SheetView") {
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
    PushView(viewModel: .init(coordinator: .init()))
}
