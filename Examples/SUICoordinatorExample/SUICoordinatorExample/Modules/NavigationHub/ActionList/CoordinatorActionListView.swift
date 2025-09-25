//
//  TabbarActionListView.swift
//
//  Copyright (c) Andres F. Lozano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import SwiftUI

struct CoordinatorActionListView: View {
    
    @Environment(\.isPresented) private var isPresented
    @StateObject var viewModel: CoordinatorActionListViewModel
    @EnvironmentObject var coordinator: NavigationHubCoordinator
    
    var body: some View {
        ZStack {
            
            Color.gray.ignoresSafeArea()
            
            List {
                actionRowButton(title: "Presents Default Tab Coordinator", systemImage: "rectangle.fill.on.rectangle.fill") {
                    await coordinator.presentDefaultTabCoordinator()
                }
                
                actionRowButton(title: "Presents Custom Tab Coordinator", systemImage: "square.grid.2x2.fill") {
                    await coordinator.presentCustomTabCoordinator()
                }
                
                actionRowButton(title: "Presents Home Coordinator", systemImage: "rectangle.bottomthird.inset.fill") {
                    await coordinator.presentHomeCoordinator()
                }
                
                actionRowButton(title: "Presents Coordinator with push navigation", systemImage: "rectangle.bottomthird.inset.fill") {
                    await coordinator.presentHomeCoordinatorWithCustomNavigation()
                }
            }
            .toolbar {
                Button {
                    Task { await viewModel.finsh() }
                } label: {
                    Text("Finish flow")
                }
            }
            .navigationTitle("Coordinators List")
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    @ViewBuilder
    private func actionRowButton(
        title: String,
        systemImage: String,
        action: @escaping () async -> Void
    ) -> some View {
        Button {
            Task { await action() }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.medium))
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundColor(Color(white: 0.7))
            }
        }
        .contentShape(Rectangle())
        .padding(.all, 8)
        .listRowBackground(
            RoundedRectangle(cornerRadius: 12)
                .shadow(
                    color: Color.black.opacity(0.5),
                    radius: 5,
                    x: 0,
                    y: 4
                )
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
        )
        .listRowSeparator(.hidden)
    }
}

#Preview {
    CoordinatorActionListView(viewModel: .init(coordinator: .init()))
}
