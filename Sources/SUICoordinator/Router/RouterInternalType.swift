//
//  RouterInternalType.swift
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

@available(iOS 17.0, *)
@MainActor
protocol RouterInternalType<Route>: RouterType {
    
    /// The sheet coordinator that manages modal presentations for this router.
    var sheetCoordinator: SheetCoordinator<AnyViewAlias> { get }
    
    /// The root view of the navigation stack, or `nil` if none has been set.
    ///
    /// This is the first route displayed when the coordinator starts. Setting it to `nil`
    /// clears the coordinator's view hierarchy.
    var mainView: Route? { get }

    /// The current push-navigation stack, mirroring the path of the active `NavigationStack`.
    ///
    /// Mutating this array drives the `NavigationStack` path directly. Appending a route pushes
    /// it onto the stack; removing the last element pops back.
    var items: [Route] { get set }

    /// A broadcast channel that fires once when the router's flow finishes.
    ///
    /// Callers waiting on `close(animated:finishFlow:)` with `finishFlow: true` subscribe
    /// to this stream. The signal is sent when the presented sheet or coordinator dismisses.
    var onFinish: AsyncBroadcast<Void> { get }
    
    /// Enqueues a sheet item for modal presentation via the sheet coordinator.
    ///
    /// This is a low-level primitive used internally by the coordinator layer. Prefer
    /// higher-level navigation methods on `CoordinatorType` instead of calling this directly.
    ///
    /// - Parameter item: The `SheetItem` describing the view and presentation style.
    func presentSheet(item: SheetItem<AnyViewAlias>) async -> Void

    /// Dismisses the current presentation and optionally waits for the flow to finish.
    ///
    /// When `finishFlow` is `true`, the method subscribes to `onFinish` and suspends
    /// until the coordinator signals completion — ensuring callers don't proceed before
    /// the dismissal animation and cleanup are fully done.
    ///
    /// - Parameters:
    ///   - animated: Whether to animate the dismissal.
    ///   - finishFlow: If `true`, waits for the `onFinish` broadcast before returning.
    func close(animated: Bool, finishFlow: Bool) async -> Void
    
    /// Synchronises the router's items with the current navigation state.
    func syncItems() async -> Void
    
    /// Clears the navigation stack and optionally removes the main view.
    ///
    /// - Parameters:
    ///   - animated: Whether to animate the operation.
    ///   - withMainView: Whether to also remove the main view from the stack.
    func clean(animated: Bool, withMainView: Bool) async -> Void
    
    /// Sets the main view of the router to the specified route.
    ///
    /// - Parameter view: The route to set as the main view, or `nil` to clear it.
    func setView(with view: Route?) async -> Void
}

@available(iOS 17.0, *)
extension RouterInternalType {
    
    // --------------------------------------------------------------------
    // MARK: Helper funcs
    // --------------------------------------------------------------------
    
    /// Removes a specific item at the given index from the sheet coordinator.
    ///
    /// - Parameter index: The index of the item to remove.
    func removeItemFromSheetCoordinator(at index: String) async {
        await sheetCoordinator.remove(at: index)
    }
    
    var isCoordinator: Bool {
        sheetCoordinator.isCoordinator
    }
}
