//
//  RouterType.swift
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
import Combine


/// A protocol representing a router in the coordinator pattern.
///
/// Routers are responsible for the actual navigation and presentation of
/// views or coordinators within a coordinator-based architecture.
public protocol RouterType: ObservableObject {
    
    // --------------------------------------------------------------------
    // MARK: Associated Type
    // --------------------------------------------------------------------
    
    /// The associated type representing the route associated with the router.
    associatedtype Route: RouteType
    
    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------
    
    /// An array of route items associated with the router.
    var items: [Route] { get set }
    
    /// The sheet coordinator associated with the router.
    var sheetCoordinator: SheetCoordinator<AnyViewAlias> { get }
    
    /// The main view associated with the router.
    var mainView: Route? { get  }
    
    /// The main view associated with the router.
    var animated: Bool { get }
    
    // --------------------------------------------------------------------
    // MARK: Functions
    // --------------------------------------------------------------------
    
    /// Navigates to a specified route with optional presentation style and animation.
    ///
    /// - Parameters:
    ///   - route: The route to navigate to.
    ///   - presentationStyle: The transition presentation style for the navigation.
    ///   - animated: A boolean value indicating whether to animate the navigation.
    @MainActor func navigate(toRoute route: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async
    
    /// Presents a view or coordinator with optional presentation style and animation.
    ///
    /// - Parameters:
    ///   - view: The view or coordinator to present.
    ///   - presentationStyle: The transition presentation style for the presentation.
    ///   - animated: A boolean value indicating whether to animate the presentation.
    @MainActor func present(_ view: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async
    
    /// Pops the top view or coordinator from the navigation stack.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the pop action.
    @MainActor func pop(animated: Bool) async
    
    /// Pops to the root of the navigation stack.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the pop action.
    @MainActor func popToRoot(animated: Bool) async
    
    /// Dismisses the currently presented view or coordinator.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the dismissal.
    @MainActor func dismiss(animated: Bool) async
    
    /// Cleans up the current view or coordinator, optionally preserving the main view.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the cleanup process.
    ///   - withMainView: A boolean value indicating whether to clean the main view.
    func clean(animated: Bool, withMainView: Bool) async -> Void
    
    /// Closes the current view or coordinator.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the closing action.
    @MainActor func close(animated: Bool) async -> Void
    
    /// Restarts the current view or coordinator, optionally animating the restart.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the restart action.
    func restart(animated: Bool) async -> Void
    
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
    func syncItems() async -> Void
}