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

/// A protocol representing a router in the coordinator pattern.
@available(iOS 17.0, *)
@MainActor
public protocol RouterType: Observable {

    associatedtype Route: RouteType

    var items: [Route] { get set }
    var sheetCoordinator: SheetCoordinator<AnyViewAlias> { get }
    var mainView: Route? { get }
    var animated: Bool { get }

    func navigate(toRoute route: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async
    func present(_ view: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async
    func pop(animated: Bool) async
    func popToRoot(animated: Bool) async
    func dismiss(animated: Bool) async
    func clean(animated: Bool, withMainView: Bool) async -> Void
    func close(animated: Bool) async -> Void
    func restart(animated: Bool) async -> Void
    func syncItems() async -> Void
}
