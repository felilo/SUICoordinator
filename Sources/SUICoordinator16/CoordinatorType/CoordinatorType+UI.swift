//
//  CoordinatorType+UI.swift
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

/// Extension providing UI-related functionality for coordinator types.
///
/// This extension bridges the gap between coordinators and SwiftUI by providing
/// methods to convert coordinators into SwiftUI views that can be integrated
/// into the view hierarchy.
public extension CoordinatorType {
    
    /// Creates and returns a SwiftUI view representation of the coordinator.
    ///
    /// This method wraps the coordinator in a `CoordinatorView`, which handles
    /// the integration between the coordinator's navigation logic and SwiftUI's
    /// view system.
    ///
    /// The returned view automatically manages:
    /// - Navigation stack presentation
    /// - Modal sheet presentations
    /// - Router state synchronization
    /// - Proper lifecycle management
    ///
    /// - Returns: A SwiftUI view that represents this coordinator's interface.
    ///
    /// ## Example Usage
    /// ```swift
    /// struct ContentView: View {
    ///     @StateObject var mainCoordinator = MainCoordinator()
    ///
    ///     var body: some View {
    ///         mainCoordinator.getView()
    ///             .onAppear {
    ///                 Task {
    ///                     await mainCoordinator.start()
    ///                 }
    ///             }
    ///     }
    /// }
    /// ```
    ///
    /// ## Integration Notes
    /// - The view automatically handles router state changes
    /// - Navigation operations are properly reflected in the UI
    /// - Modal presentations are managed transparently
    /// - The coordinator remains the source of truth for navigation state
    @ViewBuilder
    func getView() -> some View {
        CoordinatorView(dataSource: self)
    }
    
    /// Returns this coordinator's view in a type-erased `AnyView`.
    ///
    /// Use this helper when the concrete view type is irrelevant or must be
    /// hidden—e.g. when storing multiple, heterogenous coordinator views in a
    /// collection, or when an API expects a single `AnyView` value.
    ///
    /// - Returns: An `AnyView` wrapping the coordinator’s SwiftUI view.
    func viewAsAnyView() -> AnyView {
        getView().asAnyView()
    }
}
