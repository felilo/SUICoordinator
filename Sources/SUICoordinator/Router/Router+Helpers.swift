//
//  Router+Helpers.swift
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
