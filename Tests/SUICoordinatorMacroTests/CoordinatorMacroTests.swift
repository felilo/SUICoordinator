//
//  CoordinatorMacroTests.swift
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

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SUICoordinatorMacros)
import SUICoordinatorMacros

private let testMacros: [String: Macro.Type] = [
    "Coordinator": CoordinatorMacro.self,
]

final class CoordinatorMacroTests: XCTestCase {

    // MARK: - Member generation

    func test_expansion_generatesAllPropertiesAndInit() {
        assertMacroExpansion(
            """
            @Coordinator(HomeRoute.self)
            class HomeCoordinator {
                func start() async {
                    await startFlow(route: .main)
                }
            }
            """,
            expandedSource:
            """
            class HomeCoordinator {
                @MainActor
                func start() async {
                    await startFlow(route: .main)
                }

                public var router: Router<HomeRoute>

                public var uuid: String

                public var parent: (any CoordinatorType)?

                public var children: [(any CoordinatorType)] = []

                public var tagId: String?

                @MainActor public init() {
                    self.router = .init()
                    self.uuid = "\\(NSStringFromClass(type(of: self))) - \\(UUID().uuidString)"
                }

                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()

                public nonisolated func access<Member>(
                    keyPath: KeyPath<HomeCoordinator, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                public nonisolated func withMutation<Member, T>(
                    keyPath: KeyPath<HomeCoordinator, Member>,
                    _ mutation: () throws -> T
                ) rethrows -> T {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }

            @available(iOS 17.0, *)
            extension HomeCoordinator: CoordinatorType {
            }

            extension HomeCoordinator: Observable {
            }
            """,
            macros: testMacros
        )
    }

    func test_expansion_skipsInitWhenUserProvidesOne() {
        assertMacroExpansion(
            """
            @Coordinator(HomeRoute.self)
            class HomeCoordinator {
                init() {
                    self.router = .init()
                    self.uuid = "custom-id"
                }
                func start() async {}
            }
            """,
            expandedSource:
            """
            class HomeCoordinator {
                @MainActor
                init() {
                    self.router = .init()
                    self.uuid = "custom-id"
                }
                @MainActor
                func start() async {}

                public var router: Router<HomeRoute>

                public var uuid: String

                public var parent: (any CoordinatorType)?

                public var children: [(any CoordinatorType)] = []

                public var tagId: String?

                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()

                public nonisolated func access<Member>(
                    keyPath: KeyPath<HomeCoordinator, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                public nonisolated func withMutation<Member, T>(
                    keyPath: KeyPath<HomeCoordinator, Member>,
                    _ mutation: () throws -> T
                ) rethrows -> T {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }

            @available(iOS 17.0, *)
            extension HomeCoordinator: CoordinatorType {
            }

            extension HomeCoordinator: Observable {
            }
            """,
            macros: testMacros
        )
    }

    func test_expansion_skipsAlreadyDeclaredProperties() {
        assertMacroExpansion(
            """
            @Coordinator(HomeRoute.self)
            class HomeCoordinator {
                var router: Router<HomeRoute>
                func start() async {}
            }
            """,
            expandedSource:
            """
            class HomeCoordinator {
                @ObservationTracked
                var router: Router<HomeRoute>
                @MainActor
                func start() async {}

                public var uuid: String

                public var parent: (any CoordinatorType)?

                public var children: [(any CoordinatorType)] = []

                public var tagId: String?

                @MainActor public init() {
                    self.router = .init()
                    self.uuid = "\\(NSStringFromClass(type(of: self))) - \\(UUID().uuidString)"
                }

                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()

                public nonisolated func access<Member>(
                    keyPath: KeyPath<HomeCoordinator, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                public nonisolated func withMutation<Member, T>(
                    keyPath: KeyPath<HomeCoordinator, Member>,
                    _ mutation: () throws -> T
                ) rethrows -> T {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }

            @available(iOS 17.0, *)
            extension HomeCoordinator: CoordinatorType {
            }

            extension HomeCoordinator: Observable {
            }
            """,
            macros: testMacros
        )
    }

    // MARK: - Diagnostics

    func test_expansion_emitsErrorOnStruct() {
        assertMacroExpansion(
            """
            @Coordinator(HomeRoute.self)
            struct HomeCoordinator {
                func start() async {}
            }
            """,
            expandedSource:
            """
            struct HomeCoordinator {
                func start() async {}
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Coordinator can only be applied to a class declaration",
                    line: 1,
                    column: 1,
                    severity: .error
                ),
            ],
            macros: testMacros
        )
    }

    // MARK: - Route type extraction

    func test_expansion_acceptsBareRouteName() {
        assertMacroExpansion(
            """
            @Coordinator(HomeRoute)
            class HomeCoordinator {
                func start() async {}
            }
            """,
            expandedSource:
            """
            class HomeCoordinator {
                @MainActor
                func start() async {}

                public var router: Router<HomeRoute>

                public var uuid: String

                public var parent: (any CoordinatorType)?

                public var children: [(any CoordinatorType)] = []

                public var tagId: String?

                @MainActor public init() {
                    self.router = .init()
                    self.uuid = "\\(NSStringFromClass(type(of: self))) - \\(UUID().uuidString)"
                }

                @ObservationIgnored private let _$observationRegistrar = Observation.ObservationRegistrar()

                public nonisolated func access<Member>(
                    keyPath: KeyPath<HomeCoordinator, Member>
                ) {
                    _$observationRegistrar.access(self, keyPath: keyPath)
                }

                public nonisolated func withMutation<Member, T>(
                    keyPath: KeyPath<HomeCoordinator, Member>,
                    _ mutation: () throws -> T
                ) rethrows -> T {
                    try _$observationRegistrar.withMutation(of: self, keyPath: keyPath, mutation)
                }
            }

            @available(iOS 17.0, *)
            extension HomeCoordinator: CoordinatorType {
            }

            extension HomeCoordinator: Observable {
            }
            """,
            macros: testMacros
        )
    }
}
#endif
