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
    
    /// The root router associated with the coordinator.
    var root: (any RouterType) {
        return router
    }
    
    /// A boolean value indicating whether the coordinator is tabbar-coordinable.
    var isTabbarCoordinable: Bool {
        self is (any TabCoordinatable)
    }
    
    /// A boolean value indicating whether the coordinator is empty.
    var isEmptyCoordinator: Bool {
        parent == nil &&
        router.items.isEmpty &&
        router.sheetCoordinator.items.isEmpty &&
        (router.mainView == nil)
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
    func getDeepCoordinator(from value: inout TCoordinatorType?) throws -> TCoordinatorType? {
        if value?.children.last == nil {
            return value
        } else if let value = value, let tabCoordinator = getTabbarCoordinable(value) {
            return try topCoordinator(pCoodinator: try tabCoordinator.getCoordinatorSelected())
        } else {
            var last = value?.children.last
            return try getDeepCoordinator(from: &last)
        }
    }
    
    /// Removes a child coordinator from the children array.
    ///
    /// - Parameters:
    ///   - coordinator: The child coordinator to be removed.
    func removeChild(coordinator : TCoordinatorType) async {
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
    
    /// Retrieves the tabbar-coordinable object associated with the provided coordinator.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator for which to retrieve the tabbar-coordinable object.
    /// - Returns: An optional tabbar-coordinable object conforming to any TabCoordinatable.
    func getTabbarCoordinable(_ coordinator: TCoordinatorType) ->  (any TabCoordinatable)? {
        coordinator as? (any TabCoordinatable)
    }
    
    /// Starts a child coordinator.
    ///
    /// - Parameters:
    ///   - coordinator: The child coordinator to be started.
    func startChildCoordinator(_ coordinator: TCoordinatorType) {
        children.append(coordinator)
        coordinator.parent = self
    }
    
    /// Dismisses or pops the last presented sheet.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the dismissal.
    func closeLastSheet(animated: Bool = true) async {
        await router.close(animated: animated)
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
            await parent.parent?.closeLastSheet(animated: animated)
            return await parent.emptyCoordinator(animated: animated)
        }
        
        await parent.closeLastSheet(animated: animated)
        await emptyCoordinator(animated: animated)
    }
    
    /// Cleans up the coordinator.
    func swipedAway(coordinator: TCoordinatorType) async {
        let sheetCoordinator = router.sheetCoordinator
        let uuid = coordinator.uuid
        
        await sheetCoordinator.onRemoveItem = { [weak sheetCoordinator, weak coordinator] id in
            if id.contains(uuid) {
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
        _ coordinator: TCoordinatorType,
        presentationStyle: TransitionPresentationStyle,
        animated: Bool
    ) -> SheetItem<RouteType.Body> {
        var effectivePresentationStyle = presentationStyle
        
        if effectivePresentationStyle == .push {
            effectivePresentationStyle = .custom(
                transition: .move(edge: .trailing),
                animation: .easeOut,
                fullScreen: false
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
}
