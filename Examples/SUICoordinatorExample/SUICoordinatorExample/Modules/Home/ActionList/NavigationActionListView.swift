//
//  ActionListView.swift
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

struct NavigationActionListView: View {
    
    @EnvironmentObject var coordinator: HomeCoordinator
    
    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            
            List {
                actionRowButton(title: "Push NavigationView", systemImage: "arrow.forward.square.fill") {
                    await coordinator.navigateToPushView()
                }
                
                actionRowButton(title: "Presents SheetView", systemImage: "rectangle.bottomthird.inset.fill") {
                    await coordinator.presentSheet()
                }
                
                actionRowButton(title: "Presents FullscreenView", systemImage: "rectangle.fill.on.rectangle.fill") {
                    await coordinator.presentFullscreen()
                }
                
                actionRowButton(title: "Presents DetentsView", systemImage: "rectangle.split.2x1.fill") {
                    await coordinator.presentDetents()
                }
                
                actionRowButton(title: "Present with Custom Presentation", systemImage: "sparkles.rectangle.stack.fill") {
                    await coordinator.presentViewWithCustomPresentation()
                }
                
                actionRowButton(title: "Presents Tab view Coordinator", systemImage: "square.grid.2x2.fill") {
                    await coordinator.presentCustomTabCoordinator()
                }
            }
            .toolbar(content: toolbarContent)
            .navigationTitle("Navigation Action List")
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.automatic)
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
    
    @ViewBuilder
    private func toolbarContent() -> some View {
        Button {
            Task { await coordinator.finish() }
        } label: {
            Text("Finish flow")
                .font(.headline)
        }
    }
}

#Preview {
    NavigationActionListView()
}
