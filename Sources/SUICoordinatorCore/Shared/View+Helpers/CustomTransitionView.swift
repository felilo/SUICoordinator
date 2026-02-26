//
//  CustomTransitionView.swift
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

struct CustomTransitionView<Item: SheetItemType, Content: View>: View {
    
    // ---------------------------------------------------------
    // MARK: Wrapper properties
    // ---------------------------------------------------------
    
    @Binding var item: Item?
    @State private var showContent: Bool = false
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    var onDidLoad: ActionClosure? = nil
    var onDismiss: ActionClosure? = nil
    var content: Content?
    var transition: AnyTransition
    var animation: Animation?
    let animated: Bool
    let isFullScreen: Bool
    
    // ---------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------
    
    init(
        item: Binding<Item?>,
        transition: AnyTransition,
        animation: Animation?,
        animated: Bool,
        isFullScreen: Bool,
        onDismiss: ActionClosure? = nil,
        onDidLoad: ActionClosure? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self._item = item
        self.transition = transition
        self.animation = animation
        self.animated = animated
        self.onDismiss = onDismiss
        self.onDidLoad = onDidLoad
        self.isFullScreen = isFullScreen
        
        if let value = item.wrappedValue {
            self.content = content(value)
        }
    }
    
    // ---------------------------------------------------------
    // MARK: View
    // ---------------------------------------------------------
    
    var body: some View {
        ZStack {
            if !animated {
                contentItem
            } else {
                if showContent {
                    ZStack { contentItem }
                        .transition(transition)
                }
            }
        }
        .animation(animation, value: showContent)
        .onViewDidLoad { Task { @MainActor in
            await start(with: item)
        }}
    }
    
    // ---------------------------------------------------------
    // MARK: Helper views
    // ---------------------------------------------------------
    
    @ViewBuilder
    var contentItem: some View {
        if let item = item {
            content
                .onViewDidLoad { onDidLoad?("") }
                .onReceive(item.willDismiss) { _ in
                    Task { await finish() }
                }
        }
    }
    
    // ---------------------------------------------------------
    // MARK: Helper Functions
    // ---------------------------------------------------------
    
    private func start(with item: Item?) async {
        guard item != nil, animated else {
            return await finish()
        }
        
        showContent = true
    }
    
    private func finish() async {
        let duration = 0.3
        showContent = false
        
        if animated { try? await Task.sleep(for: .seconds(duration)) }
        
        guard !isFullScreen else { return (item = nil) }
        
        onDismiss?("")
    }
}
