//
//  CoordinatorType.swift
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

extension CoordinatorType {
    
    /// A Boolean value indicating whether the coordinator has been started and has a main view.
    ///
    /// This property checks if the `router`'s `mainView` is non-nil, which typically
    /// signifies that the coordinator's `start()` method has been called and has set up
    /// its initial view.
    var isRunning: Bool {
        router.mainView != nil
    }
    
    /// The root router associated with the coordinator.
    var root: (any RouterType) {
        return router
    }
    
    /// A boolean value indicating whether the coordinator is tab-coordinable.
    var isTabCoordinable: Bool {
        self is (any TabCoordinatable)
    }
    
    /// A boolean value indicating whether the coordinator is empty.
    var isEmptyCoordinator: Bool {
        parent == nil &&
        router.items.isEmpty &&
        router.sheetCoordinator.items.isEmpty &&
        router.mainView == nil
    }
    
    /// Cleans the view associated with the coordinator.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the cleaning process.
    ///   - withMainView: A boolean value indicating whether to clean the main view.
    func cleanView(animated: Bool = false, withMainView: Bool = true) async {
        if let coordinator = self as? (any TabCoordinatable) {
            await coordinator.clean()
        } else {
            await router.clean(animated: animated, withMainView: withMainView)
        }
        
        parent = nil
    }
    
    /// Retrieves a deep coordinator from the provided value.
    ///
    /// - Parameters:
    ///   - value: An inout parameter containing the coordinator value.
    /// - Returns: An optional deep coordinator of type TCoordinatorType.
    /// - Throws: An error if the deep coordinator retrieval fails.
    func getDeepCoordinator(from value: inout AnyCoordinatorType?) throws -> AnyCoordinatorType? {
        if value?.children.last == nil {
            return value
        } else if let value = value, let tabCoordinator = getTabCoordinable(value) {
            return try topCoordinator(pCoordinator: try tabCoordinator.getCoordinatorSelected())
        } else {
            var last = value?.children.last
            return try getDeepCoordinator(from: &last)
        }
    }
    
    /// Removes a child coordinator from the children array.
    ///
    /// - Parameters:
    ///   - coordinator: The child coordinator to be removed.
    func removeChild(coordinator : AnyCoordinatorType) async {
        guard let index = children.firstIndex(where: {$0.uuid == coordinator.uuid}) else {
            return
        }
        children.remove(at: index)
        await coordinator.removeChildren()
    }
    
    /// Removes all child coordinators associated with this coordinator.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the removal process.
    func removeChildren(animated: Bool = false) async {
        guard let first = children.first else { return }
        
        if let parent = first.parent as? (any TabCoordinatable) {
            parent.setCurrentPage(with: first)
        }
        
        await first.emptyCoordinator(animated: animated)
        await removeChildren()
    }
    
    /// Retrieves the tab-coordinable object associated with the provided coordinator.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator for which to retrieve the tab-coordinable object.
    /// - Returns: An optional tab-coordinable object conforming to any TabCoordinatable.
    func getTabCoordinable(_ coordinator: AnyCoordinatorType) ->  (any TabCoordinatable)? {
        coordinator as? (any TabCoordinatable)
    }
    
    /// Starts a child coordinator.
    ///
    /// - Parameters:
    ///   - coordinator: The child coordinator to be started.
    func startChildCoordinator(_ coordinator: AnyCoordinatorType) {
        children.append(coordinator)
        coordinator.parent = self
    }
    
    /// Dismisses or pops the last presented sheet.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the dismissal.
    func closeLastSheet(animated: Bool = true, finishFlow: Bool = false) async {
        await router.close(animated: animated, finishFlow: finishFlow)
    }
    
    /// Cleans up the coordinator, preparing it for dismissal.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the cleanup process.
    func emptyCoordinator(animated: Bool) async {
        guard let parent = parent else {
            await removeChildren()
            return await router.clean(animated: animated)
        }
        
        await parent.removeChild(coordinator: self)
        await cleanView(animated: false)
    }
    
    /// Finishes the coordinator, optionally dismissing it.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the finish process.
    ///   - withDismiss: A boolean value indicating whether to dismiss the coordinator.
    /// - Returns: An asynchronous void task representing the finish process.
    func finish(animated: Bool = true, withDismiss: Bool = true) async -> Void {
        guard !isEmptyCoordinator else { return }
        
        guard let parent, withDismiss else {
            return await emptyCoordinator(animated: animated)
        }
        
        if parent is (any TabCoordinatable) {
            await parent.parent?.closeLastSheet(animated: animated, finishFlow: true)
            return await parent.emptyCoordinator(animated: animated)
        }
        
        await parent.closeLastSheet(animated: animated, finishFlow: true)
        await emptyCoordinator(animated: animated)
    }
    
    /// Cleans up the coordinator.
    func swipedAway(coordinator: AnyCoordinatorType) async {
        let sheetCoordinator = router.sheetCoordinator
        let uuid = coordinator.uuid
        
        sheetCoordinator.onRemoveItem = { [weak sheetCoordinator, weak coordinator] id in
            if id.contains(uuid) {
                try? await Task.sleep(for: .seconds(0.2))
                await coordinator?.finish(animated: false, withDismiss: false)
                sheetCoordinator?.onRemoveItem = nil
            }
        }
    }

    /// Prepares a `SheetItem` for navigating to another coordinator.
    ///
    /// This function configures a `SheetItem` which is used by the `SheetCoordinator`
    /// to present the view of the target coordinator. It handles the presentation style,
    /// particularly adjusting `.push` transitions to a custom animation suitable for
    /// coordinator navigation.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator to navigate to. Its view will be embedded in the `SheetItem`.
    ///   - presentationStyle: The desired presentation style for the navigation.
    ///     If `.push` is provided, it's converted to a custom transition (`.opacity.combined(with: .move(edge: .trailing))`).
    ///   - animated: A Boolean value indicating whether the transition should be animated.
    /// - Returns: A `SheetItem` configured to present the target coordinator's view.
    func buildSheetItemForCoordinator(
        _ coordinator: AnyCoordinatorType,
        presentationStyle: TransitionPresentationStyle,
        animated: Bool
    ) -> SheetItem<AnyViewAlias> {
        var effectivePresentationStyle = presentationStyle
        
        if effectivePresentationStyle == .push {
            effectivePresentationStyle = .custom(
                transition: .move(edge: .trailing),
                animation: .default,
                fullScreen: true
            )
        } else if case .custom(let t, let a, _) = effectivePresentationStyle {
            effectivePresentationStyle = .custom(
                transition: t,
                animation: a,
                fullScreen: true
            )
        }
        
        return SheetItem(
            id: "\(coordinator.uuid) - \(effectivePresentationStyle.id)",
            animated: animated,
            presentationStyle: effectivePresentationStyle,
            isCoordinator: true,
            view: { [weak coordinator] in coordinator?.getView() }
        )
    }
    
    /// Retrieves the top coordinator in the hierarchy, optionally starting from a specified coordinator.
    ///
    /// This method traverses the coordinator hierarchy to find the deepest active coordinator,
    /// which is typically the one currently handling user interactions. It's useful for
    /// determining where new navigation operations should be performed.
    ///
    /// - Parameters:
    ///   - pCoodinator: The optional starting point for finding the top coordinator.
    ///                  If `nil`, starts from the last child of the current coordinator.
    ///
    /// - Returns: The top coordinator in the hierarchy, or `nil` if none is found.
    /// - Throws: An error if the top coordinator retrieval fails due to hierarchy issues.
    ///
    /// ## Example Usage
    /// ```swift
    /// if let topCoordinator = try coordinator.topCoordinator() {
    ///     await topCoordinator.navigate(to: newCoordinator, presentationStyle: .sheet)
    /// }
    /// ```
    func topCoordinator(pCoordinator: AnyCoordinatorType? = nil) throws -> AnyCoordinatorType? {
        if let tabCoordinator = getTabCoordinable(self) {
            var coordinatorSelected = try? tabCoordinator.getCoordinatorSelected()
            
            return try getDeepCoordinator(from: &coordinatorSelected)
        }
        
        guard children.last != nil else { return self }
        var auxCoordinator = pCoordinator ?? self.children.last
        return try getDeepCoordinator(from: &auxCoordinator)
    }
}
