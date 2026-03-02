//
//  CoordinatorMacro.swift
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

import Observation

/// A macro that transforms a plain class into a full coordinator.
///
/// Apply `@Coordinator` to a class and provide the `RouteType` as the argument.
/// The macro handles everything — no additional annotations required.
///
/// The macro injects:
/// - Stored properties: `router`, `uuid`, `parent`, `children`, `tagId`
/// - A default `init()` (skipped if you define one yourself)
/// - Full `@Observable`-equivalent observation infrastructure
/// - `CoordinatorType` and `Observable` conformances via extensions
/// - `@MainActor` isolation on all methods (via `CoordinatorType`)
///
/// All navigation methods (`navigate`, `startFlow`, `finishFlow`, `close`, `restart`,
/// `forcePresentation`, `getView`, etc.) are inherited from `CoordinatorType` protocol
/// extensions automatically.
///
/// ## Example
/// ```swift
/// @Coordinator(HomeRoute.self)
/// class HomeCoordinator {
///
///     func start() async {
///         await startFlow(route: .actionListView)
///     }
///
///     func navigateToPushView() async {
///         await navigate(toRoute: .push(coordinator: self, title: "Hello"))
///     }
/// }
/// ```
@available(iOS 17.0, *)
@attached(member, names:
    named(router),
    named(uuid),
    named(parent),
    named(children),
    named(tagId),
    named(init),
    named(_$observationRegistrar),
    named(access),
    named(withMutation)
)
@attached(memberAttribute)
@attached(extension, conformances: CoordinatorType, Observable)
public macro Coordinator<R: RouteType>(_ routeType: R.Type) =
    #externalMacro(module: "SUICoordinatorMacros", type: "CoordinatorMacro")
