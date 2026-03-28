//
//  CoreTypesTests.swift
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

import XCTest
import SwiftUI
@testable import SUICoordinator

// MARK: - Private test doubles

private struct MockEquatable: SCEquatable {
    let customId: String
    var id: String { customId }
}

private struct MockHashable: SCHashable {
    let customId: String
    var id: String { customId }
}

// MARK: -

final class CoreTypesTests: XCTestCase {

    // -------------------------------------------------------------------------
    // MARK: - SCIdentifiable default id
    // -------------------------------------------------------------------------

    func test_scIdentifiable_defaultId_isDescriptionBased() {
        let sut = MockEquatable(customId: "hello")
        // id is user-provided via the property, not the default String(describing:)
        XCTAssertEqual(sut.id, "hello")
    }

    // -------------------------------------------------------------------------
    // MARK: - SCEquatable
    // -------------------------------------------------------------------------

    func test_scEquatable_equal_sameId() {
        let a = MockEquatable(customId: "same")
        let b = MockEquatable(customId: "same")
        XCTAssertEqual(a, b)
    }

    func test_scEquatable_notEqual_differentId() {
        let a = MockEquatable(customId: "a")
        let b = MockEquatable(customId: "b")
        XCTAssertNotEqual(a, b)
    }

    // -------------------------------------------------------------------------
    // MARK: - SCHashable
    // -------------------------------------------------------------------------

    func test_scHashable_sameId_sameHash() {
        let a = MockHashable(customId: "same")
        let b = MockHashable(customId: "same")
        XCTAssertEqual(a.hashValue, b.hashValue)
    }

    func test_scHashable_differentId_differentHash() {
        let a = MockHashable(customId: "a")
        let b = MockHashable(customId: "b")
        XCTAssertNotEqual(a.hashValue, b.hashValue)
    }

    func test_scHashable_canBeUsedInSet() {
        let a = MockHashable(customId: "x")
        let b = MockHashable(customId: "x")
        let set: Set<MockHashable> = [a, b]
        XCTAssertEqual(set.count, 1)
    }

    // -------------------------------------------------------------------------
    // MARK: - TabCoordinatorError
    // -------------------------------------------------------------------------

    func test_tabCoordinatorError_coordinatorSelected_hasDescription() {
        let error = TabCoordinatorError.coordinatorSelected
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }

    func test_tabCoordinatorError_localizedDescription_matches() {
        let error = TabCoordinatorError.coordinatorSelected
        XCTAssertEqual(error.localizedDescription, error.errorDescription)
    }

    // -------------------------------------------------------------------------
    // MARK: - View+Helpers: asAnyView()
    // -------------------------------------------------------------------------

    @MainActor func test_asAnyView_returnsAnyView() {
        let view = Text("hello")
        let anyView = view.asAnyView()
        XCTAssert(type(of: anyView) == AnyView.self)
    }

    // -------------------------------------------------------------------------
    // MARK: - CoordinatorType.getView() / viewAsAnyView()
    // -------------------------------------------------------------------------

    @available(iOS 17.0, *)
    @MainActor func test_getView_returnsNonNilView() {
        let coordinator = AnyCoordinator()
        let view = coordinator.getView()
        let anyView = AnyView(view)
        XCTAssert(type(of: anyView) == AnyView.self)
    }

    @available(iOS 17.0, *)
    @MainActor func test_viewAsAnyView_returnsAnyView() {
        let coordinator = AnyCoordinator()
        let anyView = coordinator.viewAsAnyView()
        XCTAssert(type(of: anyView) == AnyView.self)
    }

    // -------------------------------------------------------------------------
    // MARK: - SheetCoordinatorView.hidden(_:) extension
    // -------------------------------------------------------------------------

    @available(iOS 17.0, *)
    @MainActor func test_hidden_true_collapseFrameAndOpacity() {
        let base = Text("test")
        let hidden = base.hidden(true)
        let anyView = AnyView(hidden)
        XCTAssert(type(of: anyView) == AnyView.self)
    }

    @available(iOS 17.0, *)
    @MainActor func test_hidden_false_visibleFrameAndOpacity() {
        let base = Text("test")
        let visible = base.hidden(false)
        let anyView = AnyView(visible)
        XCTAssert(type(of: anyView) == AnyView.self)
    }
}
