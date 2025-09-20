//
//  SheetView.swift
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

struct SheetView<Content: View, T: SheetItemType>: View {
    
    typealias Item = T
    
    // ---------------------------------------------------------
    // MARK: Wrapper properties
    // ---------------------------------------------------------
    
    @Binding var items: [Item?]
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    let index: Int
    let content: ( (Int, (Item)) -> Content)
    let onDismiss: ActionClosure?
    let onDidLoad: ActionClosure?
    let transitionStyle: TransitionPresentationStyle?
    let animated: Bool
    
    // ---------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------
    
    init(
        index: Int,
        items: Binding<[Item?]>,
        transitionStyle: TransitionPresentationStyle?,
        animated: Bool,
        @ViewBuilder content: @escaping (Int, Item) -> Content,
        onDismiss: ActionClosure? = nil,
        onDidLoad: ActionClosure?
    ) {
        self.index = index
        self._items = items
        self.content = content
        self.onDismiss = onDismiss
        self.onDidLoad = onDidLoad
        self.transitionStyle = transitionStyle
        self.animated = animated
    }
    
    // ---------------------------------------------------------
    // MARK: View
    // ---------------------------------------------------------
    
    var body: some View {
        Group {
            if let index = $items.indices.firstIndex(of: index) {
                let item = $items[index]
                
                switch getTransitionStyle(from: index) {
                case .fullScreenCover:
                    fullScreenView(
                        item: item,
                        index: index,
                        onDismiss: onDismiss
                    )
                case .sheet, .detents:
                    sheetView(
                        item: item,
                        index: index,
                        onDismiss: onDismiss
                    )
                case .custom(let transition, let animation, let fullScreen):
                    customTransitionView(
                        item: item,
                        index: index,
                        transition: transition,
                        animation: animation,
                        isFullScreen: fullScreen,
                        onDismiss: onDismiss
                    )
                default: EmptyView()
                }
            }
        }
    }
    
    // ---------------------------------------------------------
    // MARK: Helper Views
    // ---------------------------------------------------------
    
    @ViewBuilder
    private func customTransitionView(
        item: Binding<Item?>,
        index: Int,
        transition: AnyTransition,
        animation: Animation?,
        isFullScreen: Bool = false,
        onDismiss: ActionClosure?
    ) -> some View {
        if items.indices.contains(index)  {
            
            let view = CustomTransitionView(
                item: item,
                transition: transition,
                animation: animation,
                animated: animated,
                isFullScreen: isFullScreen,
                onDismiss: { _ in onDismiss?("\(index)") },
                onDidLoad: onDidLoad,
                content: { content(index, $0) }
            )
            .clearModalBackground()
            
            if isFullScreen {
                fullScreenContainer(
                    item: item,
                    animated: false,
                    index: index,
                    onDismiss: onDismiss,
                    content: { _ in view }
                )
            } else {
                view
            }
        }
    }
    
    @ViewBuilder
    private func sheetView(
        item: Binding<Item?>,
        index: Int,
        onDismiss: ActionClosure?
    ) -> some View {
        sheetContainer(
            item: item,
            animated: animated,
            index: index,
            onDismiss: onDismiss,
            content: { content(index, $0) }
        )
    }
    
    @ViewBuilder
    private func fullScreenView(
        item: Binding<Item?>,
        index: Int,
        onDismiss: ActionClosure?
    ) -> some View {
        fullScreenContainer(
            item: item,
            animated: animated,
            index: index,
            onDismiss: onDismiss,
            content: { content(index, $0) }
        )
    }
    
    // ---------------------------------------------------------
    // MARK: View containers
    // ---------------------------------------------------------
    
    @ViewBuilder
    private func fullScreenContainer(
        item: Binding<Item?>,
        animated: Bool,
        index: Int,
        onDismiss: ActionClosure? = nil,
        @ViewBuilder content: @escaping (Item) -> some View
    ) -> some View {
        defaultView
            .fullScreenCover(
                item: item,
                onDismiss: {onDismiss?(String(index))},
                content: { content($0).onViewDidLoad { onDidLoad?(String(index)) } }
            )
            .transaction { $0.disablesAnimations = !(animated) }
    }
    
    @ViewBuilder
    private func sheetContainer(
        item: Binding<Item?>,
        animated: Bool,
        index: Int,
        onDismiss: ActionClosure? = nil,
        @ViewBuilder content: @escaping (Item) -> some View
    ) -> some View {
        defaultView
            .sheet(
                item: item,
                onDismiss: { onDismiss?(String(index)) },
                content: { content($0).onViewDidLoad { onDidLoad?(String(index)) } }
            )
            .transaction { $0.disablesAnimations = !(animated) }
    }
    
    private var defaultView: some View {
        Color.blue.frame(width: 0.3, height: 0.3)
    }
    
    // ---------------------------------------------------------
    // MARK: Helper Functions
    // ---------------------------------------------------------
    
    private func getTransitionStyle(from index: Int) -> TransitionPresentationStyle? {
        guard items.indices.contains(index) else {
            return transitionStyle
        }
        
        return items[index]?.getPresentationStyle() ?? transitionStyle
    }
}
