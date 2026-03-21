//
//  Router.swift
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

import Foundation

/// A class representing a router in the coordinator pattern.
@available(iOS 17.0, *)

@Observable
public class Router<Route: RouteType>: RouterType {

    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------

    @ObservationIgnored
    private var itemManager = ItemManager<Route>()
    @ObservationIgnored
    public var animated: Bool = true
    public var sheetCoordinator: SheetCoordinator<AnyViewAlias> = .init()
    public var items: [Route] = []
    var mainView: Route?
    var onFinish = AsyncBroadcast<Void>()

    // --------------------------------------------------------------------
    // MARK: Constructor
    // --------------------------------------------------------------------

    public nonisolated init() { }

    // --------------------------------------------------------------------
    // MARK: RouterType
    // --------------------------------------------------------------------

    public func navigate(
        toRoute route: Route,
        presentationStyle: TransitionPresentationStyle? = nil,
        animated: Bool = true
    ) async -> Void {
        self.animated = animated
        if (presentationStyle ?? route.presentationStyle) == .push {
            await itemManager.addItem(route)
            return await updateItems()
        }
        await present(route, presentationStyle: presentationStyle, animated: animated)
    }

    public func present(_ view: Route, presentationStyle: TransitionPresentationStyle? = nil, animated: Bool = true) async -> Void {
        self.animated = animated

        if (presentationStyle ?? view.presentationStyle) == .push {
            return await navigate(toRoute: view, presentationStyle: presentationStyle, animated: animated)
        }

        let item = SheetItem(
            id: "\(view.id) - \(UUID())",
            animated: animated,
            presentationStyle: presentationStyle ?? view.presentationStyle,
            view: { view as AnyViewAlias }
        )

        await presentSheet(item: item)
    }

    public func pop(animated: Bool) async -> Void {
        self.animated = animated
        await self.handlePopAction()
        await self.updateItems(animated: animated)
    }

    public func popToRoot(animated: Bool = true) async -> Void {
        self.animated = animated
        await itemManager.removeAll()
        await updateItems(animated: animated)
    }

    public func dismiss(animated: Bool = true) async -> Void {
        await sheetCoordinator.removeLastSheet(animated: animated)
    }

    public func close(animated: Bool = true) async -> Void {
        await close(animated: animated, finishFlow: false)
    }

    public func clean(animated: Bool, withMainView: Bool = true) async -> Void {
        await popToRoot(animated: false)
        await sheetCoordinator.clean()
        if withMainView { setView(with: nil) }
        sheetCoordinator = .init()
    }

    public func restart(animated: Bool) async -> Void {
        if sheetCoordinator.items.isEmpty {
            await popToRoot(animated: animated)
        } else {
            await popToRoot(animated: false)
            await sheetCoordinator.clean(animated: animated)
            self.animated = animated
            await sheetCoordinator.clean()
        }
    }

    func presentSheet(item: SheetItem<AnyViewAlias>) async -> Void {
        await sheetCoordinator.presentSheet(item)
    }

    private func handlePopAction() async {
        guard !(await itemManager.areItemsEmpty()) else { return }
        await itemManager.removeLastItem()
    }

    func updateItems(animated: Bool = false) async {
        let itemsManager = await itemManager.getAllItems()
        guard items != itemsManager else { return }
        items = itemsManager
        if animated {
            try? await Task.sleep(for: .milliseconds(150))
        }
    }

    public func syncItems() async {
        let counterManagerItems = await itemManager.getAllItems().count
        let counterItems = items.count
        if counterItems != counterManagerItems {
            await itemManager.setItems(items)
            await updateItems()
        }
    }

    internal func close(animated: Bool, finishFlow: Bool) async -> Void {
        if !(await sheetCoordinator.areEmptyItems) {
            await dismiss(animated: animated)
            if finishFlow {
                let stream = await onFinish.stream()
                for await _ in stream { break }
            }
        } else if !(await itemManager.areItemsEmpty()) {
            await pop(animated: animated)
        }
    }
    
    public func setView(with view: Route?) {
        mainView = view
    }
}
