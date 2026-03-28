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

@available(iOS 17.0, *)
extension RouterType {
    
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

@available(iOS 17.0, *)
public extension RouterType {
    
    // --------------------------------------------------------------------
    // MARK: Helpers func
    // --------------------------------------------------------------------
    
    /// Removes a specific item at the given index from the sheet coordinator.
    ///
    /// - Parameter index: The index of the item to remove.
    func navigate(toRoute route: Route, presentationStyle: TransitionPresentationStyle? = nil, animated: Bool = true) async {
        await navigate(toRoute: route, presentationStyle: presentationStyle, animated: animated)
    }
    
    func present(_ view: Route, presentationStyle: TransitionPresentationStyle? = nil, animated: Bool = true) async {
        await present(view, presentationStyle: presentationStyle, animated: animated)
    }
    
    /// Pops the top view from the navigation stack.
    ///
    /// - Parameter animated: Whether to animate the transition.
    func pop(animated: Bool = true) async {
        await pop(animated: animated)
    }
    
    /// Pops all views back to the root of the navigation stack.
    ///
    /// - Parameter animated: Whether to animate the transition.
    func popToRoot(animated: Bool = true) async {
        await popToRoot(animated: animated)
    }
    
    /// Dismisses the currently presented modal.
    ///
    /// - Parameter animated: Whether to animate the dismissal.
    func dismiss(animated: Bool = true) async {
        await dismiss(animated: animated)
    }
    
    /// Clears the navigation stack and optionally removes the main view.
    ///
    /// - Parameters:
    ///   - animated: Whether to animate the operation.
    ///   - withMainView: Whether to also remove the main view from the stack.
    func clean(animated: Bool = true) async -> Void {
        await clean(animated: animated, withMainView: false)
    }
    
    /// Closes the current flow, dismissing the coordinator's presentation.
    ///
    /// - Parameter animated: Whether to animate the dismissal.
    func close(animated: Bool = true) async -> Void {
        await close(animated: animated)
    }
}
