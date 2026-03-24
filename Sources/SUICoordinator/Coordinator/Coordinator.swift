//
//  Coordinator.swift
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

/// An open class representing a coordinator in a coordinator-based architecture.
@available(iOS 17.0, *)
@Observable
open class Coordinator<Route: RouteType>: CoordinatorType, Sendable {

    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------

    public var router: Router<Route> = .init()
    public var uuid: String = UUID().uuidString
    public var parent: (any CoordinatorType)?
    public var children: [(any CoordinatorType)] = []
    public var tagId: String?

    // --------------------------------------------------------------------
    // MARK: Constructor
    // --------------------------------------------------------------------

    /// Creates a new coordinator instance.
    ///
    /// `nonisolated` so that subclasses can also declare `nonisolated init`
    /// and call `super.init()` without an actor-isolation error. The stored
    /// properties are all initialised via their inline defaults above.
    public nonisolated init() {
        // uuid cannot be set here (main-actor isolation), so it is assigned
        // in start() or on first access. Subclasses that need a stable uuid
        // before start() should set it from a @MainActor context.
    }

    // --------------------------------------------------------------------
    // MARK: Helper funcs
    // --------------------------------------------------------------------

    open func start() async {
        fatalError("This method must be overwritten")
    }
}
