//
//  Router+Helpers.swift
//  SUICoordinator
//
//  Created by Andres Lozano on 10/12/24.
//

import SwiftUI

extension RouterType {
    
    // --------------------------------------------------------------------
    // MARK: Helper funcs
    // --------------------------------------------------------------------
    
    /// Runs an action asynchronously with an optional animation.
    ///
    /// This function ensures that the given action is executed within a transaction
    /// and optionally animates the changes based on the `animated` parameter.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the action.
    ///   - action: A closure that defines the asynchronous action to run. It returns a closure
    ///             representing the UI updates to be applied.
    @MainActor func runActionWithAnimation(
        _ animated: Bool,
        action: @MainActor @escaping () async -> (() -> Void)
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
        
        await try? Task.sleep(for: .seconds(animated ? 0.2 : 0))
    }
    
    /// Removes all `nil` items from the sheet coordinator.
    ///
    /// This method ensures that the sheet coordinator does not contain invalid or nil values.
    @MainActor func removeNilItemsFromSheetCoordinator() -> Void {
        sheetCoordinator.removeAllNilItems()
    }
    
    /// Removes a specific item at the given index from the sheet coordinator.
    ///
    /// - Parameter index: The index of the item to remove.
    @MainActor func removeItemFromSheetCoordinator(at index: Int) -> Void {
        sheetCoordinator.remove(at: index)
    }
}
