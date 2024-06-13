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
import SwiftUI

/// A class representing a router in the coordinator pattern.
///
/// Routers are responsible for the actual navigation and presentation of
/// views or coordinators within a coordinator-based architecture.

public class Router<Route: RouteType>: ObservableObject, RouterType {
    
    // --------------------------------------------------------------------
    // MARK: Wrapper Properties
    // --------------------------------------------------------------------
    
    /// The first view in the navigation flow.
//    @Published public var mainView: Route?
    public var mainView: Route?
    /// The array of routes managed by the navigation router.
    @Published public var items: [Route] = []
    // The sheet coordinator for presenting sheets.
    @Published public var sheetCoordinator: SheetCoordinator<Route.Body> = .init()
    
    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------
    
    /// The coordinator associated with the router.
    public var coordinator: (any CoordinatorType)?
    
    // --------------------------------------------------------------------
    // MARK: Constructor
    // --------------------------------------------------------------------
    
    /// Creates a new instance of the navigation router.
    public init() { }
    
    // --------------------------------------------------------------------
    // MARK: RouterType
    // --------------------------------------------------------------------
    
    /// Navigates to a specified route with optional presentation style and animation.
    ///
    /// - Parameters:
    ///   - route: The route to navigate to.
    ///   - presentationStyle: The transition presentation style for the navigation.
    ///   - animated: A boolean value indicating whether to animate the navigation.
    @MainActor public func navigate(
        to route: Route,
        presentationStyle: TransitionPresentationStyle? = nil,
        animated: Bool = true
    ) async -> Void {
        if (presentationStyle ?? route.presentationStyle) == .push {
            return await runActionWithAnimation(animated) { [weak self] in
                return { self?.items.append(route) }
            }
        }
        await present(
            route,
            presentationStyle: presentationStyle,
            animated: animated)
    }
    
    /// Presents a view or coordinator with optional presentation style and animation.
    ///
    /// - Parameters:
    ///   - view: The view or coordinator to present.
    ///   - presentationStyle: The transition presentation style for the presentation.
    ///   - animated: A boolean value indicating whether to animate the presentation.
    @MainActor public func present(_ view: Route, presentationStyle: TransitionPresentationStyle? = .sheet, animated: Bool = true) async -> Void {
        
        if (presentationStyle ?? view.presentationStyle) == .push {
            return await navigate(
                to: view,
                presentationStyle: presentationStyle,
                animated: animated)
        }
        
        let item = SheetItem(
            id: view.id,
            view: view.view,
            animated: animated,
            presentationStyle: presentationStyle ?? view.presentationStyle)
        
        await presentSheet(item: item)
    }
    
    /// Pops the top view or coordinator from the navigation stack.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the pop action.
    @MainActor public func pop(animated: Bool) async -> Void {
        await runActionWithAnimation(animated) { [weak self] in
            return { self?.handlePopAction() }
        }
    }
    
    /// Pops to the root of the navigation stack.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the pop action.
    @MainActor public func popToRoot(animated: Bool = true) async -> Void {
        await runActionWithAnimation(animated) { [weak self] in
            return { self?.items.removeAll() }
        }
    }
    
    /// Pops to a specific `Route`in the navigation stack.
    ///
    /// - Parameters:
    ///   - view: The target view or coordinator to pop to.
    ///   - animated: A boolean value indicating whether to animate the pop action.
    /// - Returns: A boolean value indicating whether the pop action was successful.
    @MainActor public func popToView<T>(_ view: T, animated: Bool = true) async -> Bool {
        let name: (Any) -> String = { String(describing: $0.self) }
        guard let index = items.firstIndex(where: {
            name($0.view).replacingOccurrences(of: "()", with: "") == name(view)
        }) else { return false }
        
        let position = index + 1
        let range = position..<items.count
        if position >= items.count { return true }
        
        await runActionWithAnimation(animated) { [weak self] in
            return { self?.items.remove(atOffsets: IndexSet.init(integersIn: range)) }
        }
        
        return true
    }
    
    /// Dismisses the currently presented view or coordinator.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the dismissal.
    @MainActor public func dismiss(animated: Bool = true) async -> Void {
        await runActionWithAnimation(animated) { [weak self] in
            return { self?.sheetCoordinator.removeLastSheet(animated: animated) }
        }
    }
    
    /// Closes the current view or sheet, optionally finishing the associated flow.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the closing action.
    ///   - finishFlow: A boolean value indicating whether to finish the associated flow.
    @MainActor public func close(animated: Bool = true, finishFlow: Bool = false) async -> Void {
        if finishFlow {
            if let parent = coordinator?.parent {
                await parent.dismissLastSheet(animated: animated)
            }
            
        } else if sheetCoordinator.items.isEmpty {
            await pop(animated: animated)
        } else {
            await dismiss(animated: animated)
        }
    }
    
    /// Cleans up the current view or coordinator, optionally preserving the main view.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the cleanup process.
    ///   - withMainView: A boolean value indicating whether to clean the main view.
    @MainActor public func clean(animated: Bool, withMainView: Bool = true) async -> Void {
        await runActionWithAnimation(animated) { [weak self] in
            await self?.sheetCoordinator.clean(animated: animated)
            return {
                self?.items = []
                self?.coordinator = nil
                if withMainView { self?.mainView = nil }
            }
        }
    }
    
    /// Restarts the current view or coordinator, optionally animating the restart.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the restart action.
    @MainActor public func restart(animated: Bool) async -> Void {
        await popToRoot(animated: animated)
        await sheetCoordinator.clean(animated: animated)
    }
    
    /// Presents a sheet with a specified item.
    ///
    /// - Parameters:
    ///   - item: The sheet item containing the view to present.
    @MainActor func presentSheet(item: SheetItem<(any View)>) async -> Void {
        await sheetCoordinator.presentSheet(item, animated: item.animated)
    }
}


fileprivate extension Router {
    
    // --------------------------------------------------------------------
    // MARK: Helper funcs
    // --------------------------------------------------------------------
    
    /// Runs an action asynchronously with an optional animation.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the action.
    ///   - action: The asynchronous action to run.
    @MainActor private func runActionWithAnimation(
        _ animated: Bool,
        action: @escaping () async -> (() -> Void)
    ) async {
        let customAction = await action()
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        await withCheckedContinuation { continuation in
            withTransaction(transaction) {
                customAction()
                continuation.resume()
            }
        }
    }
    
    /// Handles the pop action by updating the navigation stack.
    private func handlePopAction() {
        guard !items.isEmpty else { return }
        items.removeLast()
    }
}
