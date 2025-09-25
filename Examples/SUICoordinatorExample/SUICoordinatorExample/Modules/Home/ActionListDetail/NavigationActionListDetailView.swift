//
//  NavigationActionListDetailView.swift
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

struct NavigationActionListDetailView: View {
    
    @StateObject var viewModel: NavigationActionListDetailViewModel
    @State private var counter = 0
    @State var bgColor: Color = Self.randomColor()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(coordinator: HomeCoordinator, title: String) {
        self._viewModel = .init(wrappedValue: .init(
            coordinator: coordinator,
            title: title
        ))
    }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            List {
                actionRowButton(title: "Navigate To PushView") { await viewModel.navigateToPushView() }
                actionRowButton(title: "Presents SheetView") { await viewModel.presentSheet() }
                actionRowButton(title: "Presents FullscreenView") { await viewModel.presentFullscreen() }
                actionRowButton(title: "Presents DetentsView") { await viewModel.presentDetentsView() }
                actionRowButton(title: "Presents View With Custom Presentation") { await viewModel.presentViewWithCustomPresentation() }
                actionRowButton(title: "Restart Coordinator") { await viewModel.restartCoordinator() }
                actionRowButton(title: "Close View") { await viewModel.close() }
                actionRowButton(title: "Finish Coordinator") { await viewModel.finish() }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("\(viewModel.title)")
            .toolbar { ToolbarItemGroup {
                Text("Counter: \(counter)")
            }}
        }
        .onReceive(timer) { _ in counter += 1 }
    }
    
    @ViewBuilder
    private func actionRowButton(
        title: String,
        action: @escaping () async -> Void
    ) -> some View {
        
        Button {
            Task { await action() }
        } label: {
            HStack(spacing: 16) {
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
                    y: 2
                )
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
        )
        .listRowSeparator(.hidden)
    }
    
    private static func randomColor() -> Color {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        return Color(red: red, green: green, blue: blue)
    }
}

#Preview {
    NavigationActionListDetailView(coordinator: .init(), title: "1")
}