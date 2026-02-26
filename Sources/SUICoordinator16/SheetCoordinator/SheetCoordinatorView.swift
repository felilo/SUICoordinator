//
//  SheetCoordinating.swift
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
import Combine

struct SheetCoordinatorView: ViewModifier {

    // ---------------------------------------------------------
    // MARK: typealias
    // ---------------------------------------------------------

    typealias Action = ((String) -> Void)
    typealias Value = AnyViewAlias

    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------

    let coordinator: SheetCoordinator<Value>
    var isLast: Bool
    var onDissmis: ActionClosure?
    var onDidLoad: ActionClosure?

    // ---------------------------------------------------------
    // MARK: ViewModifier
    // ---------------------------------------------------------

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            NewSheetContainer(
                coordinator: coordinator,
                isLast: isLast,
                onDissmis: onDissmis,
                onDidLoad: onDidLoad,
                content: content
            )
        } else {
            OldSheetContainer(
                coordinator: coordinator,
                isLast: isLast,
                onDissmis: onDissmis,
                onDidLoad: onDidLoad,
                content: content
            )
        }
    }
}


// iOS 17+ Container
// When SheetCoordinator adopts @Observable, replace @ObservedObject with @Bindable here.
@available(iOS 17.0, *)
private struct NewSheetContainer<Content: View>: View {

    @ObservedObject var coordinator: SheetCoordinator<AnyViewAlias>
    @State var index = 0
    var isLast: Bool
    var onDissmis: ActionClosure?
    var onDidLoad: ActionClosure?
    let content: Content

    var body: some View {
        content
            .overlay {
                VStack {
                    SheetView(
                        index: index,
                        items: $coordinator.items,
                        transitionStyle: coordinator.lastPresentationStyle,
                        animated: coordinator.animated ?? true,
                        content: buildContent,
                        onDismiss: onDissmis,
                        onDidLoad: onDidLoad
                    )
                    .hidden($coordinator.items.isEmpty || isLast)
                }
            }
    }

    private func buildContent(with index: Int, item: SheetItem<AnyViewAlias>) -> some View {
        let view = item.view()?.asAnyView()
            .sheetCoordinator(
                coordinator: coordinator,
                index: coordinator.getNextIndex(index),
                isLast: coordinator.isLastIndex(index),
                onDissmis: onDissmis,
                onDidLoad: onDidLoad
            )
        return addSheet(to: view, with: item.presentationStyle)
    }

    @ViewBuilder
    private func addSheet(to content: some View, with presentationStyle: TransitionPresentationStyle) -> some View {
        switch presentationStyle {
            case .detents(let data): content.presentationDetents(data)
            default: content
        }
    }
}


// iOS 16 Container
private struct OldSheetContainer<Content: View>: View {

    @ObservedObject var coordinator: SheetCoordinator<AnyViewAlias>
    @State var index = 0
    var isLast: Bool
    var onDissmis: ActionClosure?
    var onDidLoad: ActionClosure?
    let content: Content

    var body: some View {
        content
            .overlay {
                VStack {
                    SheetView(
                        index: index,
                        items: $coordinator.items,
                        transitionStyle: coordinator.lastPresentationStyle,
                        animated: coordinator.animated ?? true,
                        content: buildContent,
                        onDismiss: onDissmis,
                        onDidLoad: onDidLoad
                    )
                    .hidden($coordinator.items.isEmpty || isLast)
                }
            }
    }

    private func buildContent(with index: Int, item: SheetItem<AnyViewAlias>) -> some View {
        let view = item.view()?.asAnyView()
            .sheetCoordinator(
                coordinator: coordinator,
                index: coordinator.getNextIndex(index),
                isLast: coordinator.isLastIndex(index),
                onDissmis: onDissmis,
                onDidLoad: onDidLoad
            )
        return addSheet(to: view, with: item.presentationStyle)
    }

    @ViewBuilder
    private func addSheet(to content: some View, with presentationStyle: TransitionPresentationStyle) -> some View {
        switch presentationStyle {
            case .detents(let data): content.presentationDetents(data)
            default: content
        }
    }
}


extension View {
    func hidden(_ isHidden: Bool) -> some View {
        self.frame(maxHeight: !isHidden ? .infinity : 0)
            .opacity(!isHidden ? 1 : 0)
    }
}
