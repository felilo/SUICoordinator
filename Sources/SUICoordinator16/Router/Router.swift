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

import Combine
import Foundation

/// A class representing a router in the coordinator pattern.
public class Router<Route: RouteType>: ObservableObject, RouterType {
    
    // --------------------------------------------------------------------
    // MARK: Wrapper Properties
    // --------------------------------------------------------------------
    
    @Published public var mainView: Route?
    @Published public var items: [Route] = []
    @Published public var sheetCoordinator: SheetCoordinator<AnyViewAlias> = .init()
    
    public var animated: Bool = true
    
    private let itemManager = ItemManager<Route>()
    
    // --------------------------------------------------------------------
    // MARK: Constructor
    // --------------------------------------------------------------------
    
    public init() { }
    
    // --------------------------------------------------------------------
    // MARK: RouterType
    // --------------------------------------------------------------------
    
    @MainActor public func navigate(
        toRoute route: Route,
        presentationStyle: TransitionPresentationStyle? = nil,
        animated: Bool = true
    ) async -> Void {
        self.animated = animated
        if (presentationStyle ?? route.presentationStyle) == .push {
            await itemManager.addItem(route)
            return await updateItems()
        }
        await present(
            route,
            presentationStyle: presentationStyle,
            animated: animated)
    }
    
    @MainActor public func present(_ view: Route, presentationStyle: TransitionPresentationStyle? = nil, animated: Bool = true) async -> Void {
        self.animated = animated
        
        if (presentationStyle ?? view.presentationStyle) == .push {
            return await navigate(
                toRoute: view,
                presentationStyle: presentationStyle,
                animated: animated)
        }
        
        let item = SheetItem(
            id: "\(view.id) - \(UUID())",
            animated: animated,
            presentationStyle: presentationStyle ?? view.presentationStyle,
            view: { view as AnyViewAlias }
        )
        
        await presentSheet(item: item)
    }
    
    @MainActor public func pop(animated: Bool) async -> Void {
        self.animated = animated
        await self.handlePopAction()
        await self.updateItems()
    }
    
    @MainActor public func popToRoot(animated: Bool = true) async -> Void {
        self.animated = animated
        await itemManager.removeAll()
        await updateItems()
    }
    
    @MainActor public func dismiss(animated: Bool = true) async -> Void {
        await sheetCoordinator.removeLastSheet(animated: animated)
    }
    
    @MainActor public func close(animated: Bool = true) async -> Void {
        await close(animated: animated, finishFlow: false)
    }
    
    @MainActor public func clean(animated: Bool, withMainView: Bool = true) async -> Void {
        await popToRoot(animated: false)
        sheetCoordinator = .init()
        if withMainView { mainView = nil }
    }
    
    @MainActor public func restart(animated: Bool) async -> Void {
        if sheetCoordinator.items.isEmpty {
            await popToRoot(animated: animated)
        } else {
            async let _ = await popToRoot(animated: true)
            try? await Task.sleep(for: .seconds(0.2))
            await sheetCoordinator.clean(animated: animated)
            self.animated = animated
            sheetCoordinator = .init()
        }
    }
    
    @MainActor func presentSheet(item: SheetItem<AnyViewAlias>) async -> Void {
        await sheetCoordinator.presentSheet(item)
    }
    
    private func handlePopAction() async {
        guard !(await itemManager.areItemsEmpty()) else { return }
        await itemManager.removeLastItem()
    }
    
    @MainActor
    func updateItems() async {
        let itemsManager = await itemManager.getAllItems()
        guard items != itemsManager else { return }
        items = itemsManager
    }
    
    @MainActor
    public func syncItems() async {
        let counterManagerItems = await itemManager.getAllItems().count
        let counterItems = items.count
        
        if counterItems != counterManagerItems {
            await itemManager.setItems(items)
            await updateItems()
        }
    }
    
    @MainActor internal func close(animated: Bool, finishFlow: Bool) async -> Void {
        if !(await sheetCoordinator.areEmptyItems) {
            await dismiss(animated: animated)
            if finishFlow {
                try? await Task.sleep(for: .milliseconds(animated ? 600 : 100))
            }
        } else if !(await itemManager.areItemsEmpty()) {
            await pop(animated: animated)
        }
    }
}
