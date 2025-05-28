//
//  RouteType.swift
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

/// Protocol defining the requirements for a route in the Coordinator pattern.
///
/// `RouteType` represents the different views or navigation actions that can be handled by a coordinator
/// or router within an application. Routes encapsulate both the destination view and how it should be presented.
///
/// Routes are the fundamental building blocks of navigation in the coordinator pattern, providing a
/// type-safe way to define navigation destinations and their presentation behavior.
///
/// ## Key Features
/// - **Type Safety**: Each route defines its specific view type and presentation behavior
/// - **Presentation Control**: Routes specify how they should be presented (push, sheet, etc.)
/// - **View Builder Support**: Routes can return complex view hierarchies using `@ViewBuilder`
/// - **Hashable Conformance**: Routes can be used in navigation stacks and collections
///
/// ## Example Implementation
/// ```swift
/// enum AppRoute: RouteType {
///     case home
///     case profile(User)
///     case settings
///
///     var presentationStyle: TransitionPresentationStyle {
///         switch self {
///         case .home, .profile:
///             return .push
///         case .settings:
///             return .sheet
///         }
///     }
///
///     @ViewBuilder @MainActor
///     var view: Body {
///         switch self {
///         case .home:
///             HomeView()
///         case .profile(let user):
///             ProfileView(user: user)
///         case .settings:
///             SettingsView()
///         }
///     }
/// }
/// ```
public protocol RouteType: SCHashable {
    
    // ---------------------------------------------------------
    // MARK: typealias
    // ---------------------------------------------------------
    
    /// A type alias representing the body of the route, conforming to the View protocol.
    ///
    /// This represents any SwiftUI view that can be presented as the destination for this route.
    typealias Body = (any View)
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The transition style for presenting the view.
    ///
    /// This property determines how the route's view should be presented when navigated to.
    /// Common values include `.push` for navigation stack presentation, `.sheet` for modal presentation,
    /// and `.fullScreenCover` for full-screen modal presentation.
    var presentationStyle: TransitionPresentationStyle { get }
    
    /// The body of the route, conforming to the View protocol.
    ///
    /// This computed property returns the SwiftUI view that represents the destination for this route.
    /// Use the `@ViewBuilder` attribute to enable view builder syntax for complex view hierarchies.
    ///
    /// - Important: This property is marked with `@MainActor` to ensure it runs on the main thread,
    ///              which is required for SwiftUI view creation.
    @ViewBuilder @MainActor var view: Body { get }
}

/// Extension providing utility methods for RouteType conforming types.
extension RouteType {
    
    /// Creates a view from the provided content closure with proper error handling.
    ///
    /// This method safely creates a view from a content closure, providing a fallback
    /// empty view if the content creation fails. It also ensures proper view identification
    /// for SwiftUI's view diffing system.
    ///
    /// - Parameter content: A closure that returns an optional view body.
    /// - Returns: A properly configured SwiftUI view, either from the content or an empty fallback.
    ///
    /// - Note: This method is used internally by the router system to safely create views
    ///         from route definitions.
    func getView(from content: () -> (Body?)) -> any View {
        var view = AnyView(EmptyView()).id(UUID().uuidString)
        
        if let v = content() {
            view = AnyView(v).id(String(describing: v.self))
        }
        
        return view
    }
}
