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
///
/// `Router` is responsible for the actual navigation and presentation of views or coordinators
/// within a coordinator-based architecture. It manages navigation stacks, modal presentations,
/// and provides a unified interface for all navigation operations.
///
/// ## Key Features
/// - **Navigation Stack Management**: Handles push/pop operations in navigation stacks
/// - **Modal Presentation**: Manages sheets, full-screen covers, and custom presentations
/// - **Animation Control**: Configurable animation for all navigation operations
/// - **Thread Safety**: Uses actors internally for safe concurrent access
/// - **Flexible Presentation**: Supports multiple presentation styles and transitions
///
/// ## Navigation Types
/// - **Push Navigation**: Added to navigation stack for hierarchical navigation
/// - **Modal Presentation**: Presented as sheets or full-screen covers
/// - **Custom Transitions**: Support for custom presentation animations
///
/// ## Example Usage
/// ```swift
/// let router = Router<AppRoute>()
///
/// // Navigate with push (adds to navigation stack)
/// await router.navigate(toRoute: .profile(user), presentationStyle: .push)
///
/// // Present modally
/// await router.present(.settings, presentationStyle: .sheet)
///
/// // Pop back
/// await router.pop(animated: true)
/// ```
public class Router<Route: RouteType>: ObservableObject, RouterType {
    
    // --------------------------------------------------------------------
    // MARK: Wrapper Properties
    // --------------------------------------------------------------------
    
    /// The first view in the navigation flow.
    ///
    /// This represents the root view of the navigation hierarchy. When set, it becomes
    /// the base view from which all other navigation operations occur.
    @Published public var mainView: Route?
    
    /// The array of routes managed by the navigation router.
    ///
    /// This array represents the current navigation stack. Each route in the array
    /// corresponds to a view in the navigation hierarchy, with the last item being
    /// the currently visible view.
    @Published public var items: [Route] = []
    
    /// The sheet coordinator for presenting sheets.
    ///
    /// This coordinator manages all modal presentations (sheets, full-screen covers, etc.)
    /// and provides a unified interface for modal navigation operations.
    @Published public var sheetCoordinator: SheetCoordinator<AnyViewAlias> = .init()
    
    /// Controls whether navigation operations should be animated.
    ///
    /// This property affects all navigation operations performed by the router.
    /// When `true`, transitions are animated; when `false`, they occur immediately.
    public var animated: Bool = true
    
    /// Thread-safe item manager for navigation stack operations.
    ///
    /// This actor-based manager ensures safe concurrent access to the navigation items,
    /// preventing race conditions during navigation operations.
    private let itemManager = ItemManager<Route>()
    
    // --------------------------------------------------------------------
    // MARK: Constructor
    // --------------------------------------------------------------------
    
    /// Creates a new instance of the navigation router.
    ///
    /// Initializes an empty router ready to handle navigation operations.
    /// The router starts with no navigation stack and no presented sheets.
    public init() { }
    
    // --------------------------------------------------------------------
    // MARK: RouterType
    // --------------------------------------------------------------------
    
    /// Navigates to a specified route with optional presentation style and animation.
    ///
    /// This method handles navigation to a new route, automatically determining whether
    /// to use push navigation or modal presentation based on the presentation style.
    ///
    /// - Parameters:
    ///   - route: The route to navigate to.
    ///   - presentationStyle: The transition presentation style for the navigation.
    ///                        If `nil`, uses the route's default presentation style.
    ///   - animated: A boolean value indicating whether to animate the navigation.
    ///
    /// - Note: If the presentation style is `.push`, the route is added to the navigation stack.
    ///         Otherwise, it's presented modally.
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
    
    /// Presents a view or coordinator with optional presentation style and animation.
    ///
    /// This method handles modal presentation of routes, creating sheet items and
    /// managing them through the sheet coordinator.
    ///
    /// - Parameters:
    ///   - view: The view or coordinator to present.
    ///   - presentationStyle: The transition presentation style for the presentation.
    ///                        Defaults to `.sheet` if not specified.
    ///   - animated: A boolean value indicating whether to animate the presentation.
    ///
    /// - Note: If the presentation style is `.push`, this method delegates to `navigate(toRoute:)`.
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
    
    /// Pops the top view or coordinator from the navigation stack.
    ///
    /// This method removes the most recent item from the navigation stack,
    /// effectively navigating back to the previous view.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the pop action.
    ///
    /// - Note: If the navigation stack is empty, this method has no effect.
    @MainActor public func pop(animated: Bool) async -> Void {
        self.animated = animated
        await self.handlePopAction()
        await self.updateItems()
    }
    
    /// Pops to the root of the navigation stack.
    ///
    /// This method removes all items from the navigation stack, returning to
    /// the root view of the navigation hierarchy.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the pop action.
    @MainActor public func popToRoot(animated: Bool = true) async -> Void {
        self.animated = animated
        
        await itemManager.removeAll()
        await updateItems()
    }

    /// Dismisses the currently presented view or coordinator.
    ///
    /// This method dismisses the topmost modal presentation, such as a sheet
    /// or full-screen cover.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the dismissal.
    ///
    /// - Note: If no modal presentations are active, this method has no effect.
    @MainActor public func dismiss(animated: Bool = true) async -> Void {
        await sheetCoordinator.removeLastSheet(animated: animated)
    }
    
    /// Closes the current view or coordinator.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the closing action.
    @MainActor public func close(animated: Bool = true) async -> Void {
        await close(animated: animated, finishFlow: false)
    }
    
    /// Cleans up the current view or coordinator, optionally preserving the main view.
    ///
    /// This method performs a complete cleanup of the router state, removing all
    /// navigation items and modal presentations.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the cleanup process.
    ///   - withMainView: A boolean value indicating whether to clear the main view.
    ///                   When `true`, the main view is also set to `nil`.
    @MainActor public func clean(animated: Bool, withMainView: Bool = true) async -> Void {
        await popToRoot(animated: false)
        sheetCoordinator = .init()
        
        if withMainView { mainView = nil }
    }
    
    /// Restarts the current view or coordinator, optionally animating the restart.
    ///
    /// This method provides a complete restart of the navigation state, cleaning up
    /// both navigation stack and modal presentations with intelligent timing.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the restart action.
    @MainActor public func restart(animated: Bool) async -> Void {
        if sheetCoordinator.items.isEmpty {
            await popToRoot(animated: animated)
        } else {
            if #available(iOS 17.0, *) {
                await popToRoot(animated: false)
            } else {
                async let  _ =  await popToRoot(animated: true)
                try? await Task.sleep(for: .seconds(0.2))
            }
            
            await sheetCoordinator.clean(animated: animated)
            self.animated = animated
            
            sheetCoordinator = .init()
        }
    }
    
    /// Presents a sheet with a specified item.
    ///
    /// This internal method handles the actual presentation of sheet items
    /// through the sheet coordinator.
    ///
    /// - Parameters:
    ///   - item: The sheet item containing the view to present.
    @MainActor func presentSheet(item: SheetItem<AnyViewAlias>) async -> Void {
        await sheetCoordinator.presentSheet(item)
    }
    
    /// Handles the pop action by updating the navigation stack.
    ///
    /// This private method performs the actual removal of the last item
    /// from the navigation stack during pop operations.
    private func handlePopAction() async {
        guard !(await itemManager.areItemsEmpty()) else { return }
        
        await itemManager.removeLastItem()
    }
    
    /// Updates the published items array with the current navigation stack state.
    ///
    /// This method synchronizes the published items array with the internal
    /// item manager state, triggering UI updates when the navigation stack changes.
    @MainActor
    func updateItems() async {
        let itemsManager = await itemManager.getAllItems()
        
        guard items != itemsManager else { return }
        
        items = itemsManager
    }
    
    /// Synchronizes the router's items array with the internal item manager state.
    ///
    /// This method ensures consistency between the published items array and the internal
    /// navigation stack state. It's particularly useful for resolving state discrepancies
    /// that might occur during complex navigation operations or when the navigation stack
    /// gets out of sync with the UI representation.
    ///
    /// The synchronization process compares the count of items in the published array
    /// with the internal item manager's count. If there are fewer items in the published
    /// array, it removes the excess items from the manager and updates the published state.
    ///
    /// This method is typically called automatically by the router's internal mechanisms
    /// and should rarely need to be called directly by client code.
    @MainActor
    public func syncItems() async {
        let counterManagerItems = await itemManager.getAllItems().count
        let counterItems = items.count
        
        if counterItems != counterManagerItems {
            await itemManager.setItems(items)
            await updateItems()
        }
    }
    
    /// Closes the current view or sheet, optionally finishing the associated flow.
    ///
    /// This method intelligently determines whether to dismiss a modal presentation
    /// or pop from the navigation stack based on the current navigation state.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the closing action.
    ///   - finishFlow: A boolean value indicating whether to finish the associated flow.
    ///                 Currently unused but reserved for future functionality.
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
