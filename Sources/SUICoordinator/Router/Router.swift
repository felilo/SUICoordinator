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

/// Manages navigation state for a single coordinator scope.
///
/// `Router` is the central navigation object used by every coordinator. It owns two
/// orthogonal navigation stacks:
///
/// - **Push stack** (`items`) — drives a `NavigationStack` inside `RouterView`.
/// - **Sheet stack** (`sheetCoordinator`) — drives modal sheet and full-screen-cover
///   presentation via `SheetCoordinator`.
///
/// Navigation is performed through `RouterType` methods (`navigate`, `present`, `pop`,
/// `dismiss`, etc.). `RouterView` renders both stacks and feeds dismissal confirmations
/// back through `didPop` and `sheetDidDismiss` so async callers can await completion.
@available(iOS 17.0, *)
@Observable
public class Router<Route: RouteType>: RouterInternalType {

    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------

    @ObservationIgnored
    private var itemManager = ItemManager<Route>()
    /// Whether navigation transitions are animated by default.
    @ObservationIgnored
    public var animated: Bool = true
    /// The sheet presentation stack for this router's scope.
    var sheetCoordinator: SheetCoordinator<AnyViewAlias> = .init()
    /// The current push-navigation stack, observed by `RouterView`.
    public var items: [Route] = []
    /// The root view of this router's `NavigationStack`. Set once by `Coordinator.start()`.
    public var mainView: Route?
    /// Broadcast fired by `RouterView` after a coordinator sheet finishes dismissing,
    /// used to unblock `close(animated:finishFlow:true)` callers.
    var sheetDidDismiss: AsyncBroadcast<Void> = .init()
    /// Broadcast fired by `RouterView` after a push-pop animation completes,
    /// used to unblock `pop` and `popToRoot` callers when items remain.
    var didPop: AsyncBroadcast<Void> = .init()

    // --------------------------------------------------------------------
    // MARK: Constructor
    // --------------------------------------------------------------------

    /// Creates a new, empty `Router`.
    public nonisolated init() { }

    // --------------------------------------------------------------------
    // MARK: RouterType
    // --------------------------------------------------------------------

    /// Navigates to `route` using its declared or overridden presentation style.
    ///
    /// If the resolved style is `.push`, the route is appended to the push stack.
    /// Otherwise it is presented modally via `present(_:presentationStyle:animated:)`.
    ///
    /// - Parameters:
    ///   - route: The destination route.
    ///   - presentationStyle: Overrides `route.presentationStyle` when non-nil.
    ///   - animated: Whether the transition is animated. Defaults to `true`.
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

    /// Presents `view` modally using the given or default presentation style.
    ///
    /// If the resolved style is `.push`, the call is forwarded to `navigate` instead.
    /// Otherwise a `SheetItem` is created and added to `sheetCoordinator`.
    ///
    /// - Parameters:
    ///   - view: The route to present.
    ///   - presentationStyle: Overrides `view.presentationStyle` when non-nil.
    ///   - animated: Whether the presentation is animated. Defaults to `true`.
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

    /// Pops the top route from the push stack.
    ///
    /// When items remain after the pop, the function suspends on `didPop` until
    /// `RouterView` confirms the animation has completed.
    ///
    /// - Parameter animated: Whether the pop transition is animated.
    public func pop(animated: Bool) async -> Void {
        self.animated = animated
        await self.handlePopAction()
        await self.updateItems(animated: animated)
        if !(await itemManager.areItemsEmpty()) {
            let stream = await didPop.stream()
            for await _ in stream { break }
        }
    }

    /// Clears the push stack and returns to the root view.
    ///
    /// When items remain after clearing, the function suspends on `didPop` until
    /// `RouterView` confirms the animation has completed.
    ///
    /// - Parameter animated: Whether the transition is animated. Defaults to `true`.
    public func popToRoot(animated: Bool = true) async -> Void {
        self.animated = animated
        await itemManager.removeAll()
        await updateItems(animated: animated)
        if !(await itemManager.areItemsEmpty()) {
            let stream = await didPop.stream()
            for await _ in stream { break }
        }
    }

    /// Dismisses the topmost sheet in the sheet stack.
    ///
    /// - Parameter animated: Whether the dismissal is animated. Defaults to `true`.
    public func dismiss(animated: Bool = true) async -> Void {
        await sheetCoordinator.removeLastSheet(animated: animated)
    }

    /// Closes the topmost presented context — dismisses the last sheet if one exists,
    /// otherwise pops the push stack.
    ///
    /// - Parameter animated: Whether the transition is animated. Defaults to `true`.
    public func close(animated: Bool = true) async -> Void {
        await close(animated: animated, finishFlow: false)
    }

    /// Resets the router to its initial empty state.
    ///
    /// Pops the push stack to root and cleans the sheet stack concurrently, then clears
    /// `mainView` when `withMainView` is `true` and replaces `sheetCoordinator` with a
    /// fresh instance.
    ///
    /// - Parameters:
    ///   - animated: Whether transitions are animated.
    ///   - withMainView: Whether to also clear `mainView`. Defaults to `true`.
    public func clean(animated: Bool, withMainView: Bool = true) async -> Void {
        async let stackNav = popToRoot(animated: false)
        async let sheetCoordinator = sheetCoordinator.clean()
        let _ = await (stackNav, sheetCoordinator)
        
        await itemManager.removeAll()
        await updateItems()
        
        if withMainView { setView(with: nil) }
        self.sheetCoordinator = .init()
    }

    /// Returns the router to its root view while preserving `mainView`.
    ///
    /// If the sheet stack is empty, only the push stack is popped to root. Otherwise
    /// both stacks are cleared concurrently.
    ///
    /// - Parameter animated: Whether transitions are animated.
    public func restart(animated: Bool) async -> Void {
        if sheetCoordinator.items.isEmpty {
            await popToRoot(animated: animated)
        } else {
            async let _ = await popToRoot(animated: animated)
            await sheetCoordinator.clean(animated: animated)
            self.animated = animated
        }
    }

    /// Appends a pre-built `SheetItem` to the sheet stack.
    ///
    /// Primarily used by `CoordinatorType` when navigating to a child coordinator,
    /// where the item is constructed externally before being handed to the router.
    ///
    /// - Parameter item: The sheet item to present.
    public func presentSheet(item: SheetItem<AnyViewAlias>) async -> Void {
        await sheetCoordinator.presentSheet(item)
    }

    /// Syncs the observable `items` array from `itemManager` when they differ.
    ///
    /// - Parameter animated: Passed through to callers that need to track animation state;
    ///   not used directly by this method.
    func updateItems(animated: Bool = false) async {
        let itemsManager = await itemManager.getAllItems()
        guard items != itemsManager else { return }
        items = itemsManager
    }

    /// Reconciles `items` with `itemManager` after SwiftUI may have mutated the array
    /// directly (e.g. the user pops via the navigation bar back button).
    ///
    /// When the counts differ, `itemManager` is updated to match `items` and the
    /// observable array is refreshed.
    func syncItems() async {
        let counterManagerItems = await itemManager.getAllItems().count
        let counterItems = items.count
        if counterItems != counterManagerItems {
            await itemManager.setItems(items)
            await updateItems()
        }
    }

    /// Internal implementation of `close` that optionally waits for the finish signal.
    ///
    /// When `finishFlow` is `true`, the function suspends on `sheetDidDismiss` after dismissing
    /// the sheet, blocking until `RouterView` confirms the coordinator sheet has
    /// disappeared. When the sheet stack is empty, falls back to a push-stack pop.
    ///
    /// - Parameters:
    ///   - animated: Whether the transition is animated.
    ///   - finishFlow: When `true`, awaits `sheetDidDismiss` after dismissal.
    func close(animated: Bool, finishFlow: Bool) async -> Void {
        if !(await sheetCoordinator.areEmptyItems) {
            await dismiss(animated: animated)
            if finishFlow {
                let stream = await sheetDidDismiss.stream()
                for await _ in stream { break }
            }
        } else if !(await itemManager.areItemsEmpty()) {
            await pop(animated: animated)
        }
    }
    
    /// Sets `mainView` to `view`, establishing (or clearing) the root of the navigation stack.
    func setView(with view: Route?) {
        mainView = view
    }
    
    /// Removes the last item from `itemManager`, guarding against an empty stack.
    private func handlePopAction() async {
        guard !(await itemManager.areItemsEmpty()) else { return }
        await itemManager.removeLastItem()
    }
}
