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

/// `RouteType` is a typealias used for defining route representations in the Coordinator pattern.
///
/// It represents any value (typically an enum or struct) that both:
/// - Conforms to `RoutePresentationType` (declares navigation presentation style and identity)
/// - Implements SwiftUI's `View` protocol (provides destination UI)
///
/// By conforming to `RouteType`, you enable your enum or struct to act as a navigation route within your coordinator–
/// encapsulating both the "what to show" and "how to present" aspects in a type-safe, declarative way.
///
/// ## Example
/// ```swift
/// enum AppRoute: RouteType {
///     case home
///     case details(id: Int)
///
///     var presentationStyle: TransitionPresentationStyle {
///         switch self {
///         case .home:
///             return .push
///         case .details:
///             return .sheet
///         }
///     }
///
///     var body: some View {
///         switch self {
///         case .home: HomeView()
///         case .details(let id): DetailsView(id: id)
///         }
///     }
/// }
/// ```
///
/// Use `RouteType` when you want to describe stack-based or modal navigation with clear ownership of both view and presentation.
///
public typealias RouteType = RoutePresentationType & View

/// Protocol that supplies presentation and identity requirements for `RouteType`.
///
/// - Requires a `presentationStyle` indicating navigation semantics (push, sheet, fullScreen, etc.)
/// - Inherits from `SCHashable` for use in navigation stacks
public protocol RoutePresentationType: SCHashable {
    /// The transition style for presenting the view.
    ///
    /// This property determines how the route's view should be presented when navigated to.
    /// Supported values include `.push` (navigation stack), `.sheet` (modal), `.fullScreenCover`, etc.
    nonisolated var presentationStyle: TransitionPresentationStyle { get }
}
