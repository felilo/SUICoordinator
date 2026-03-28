//
//  DefaultRouteTests.swift
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

@MainActor
final class DefaultRouteTests: XCTestCase {

    // MARK: - init / presentationStyle

    func test_init_storesPresentationStyle() {
        let sut = DefaultRoute(presentationStyle: .sheet, content: { nil })
        XCTAssertEqual(sut.presentationStyle, .sheet)
    }

    func test_init_storesPresentationStyle_push() {
        let sut = DefaultRoute(presentationStyle: .push, content: { nil })
        XCTAssertEqual(sut.presentationStyle, .push)
    }

    func test_init_storesPresentationStyle_fullScreenCover() {
        let sut = DefaultRoute(presentationStyle: .fullScreenCover, content: { nil })
        XCTAssertEqual(sut.presentationStyle, .fullScreenCover)
    }

    func test_init_storesPresentationStyle_detents() {
        let sut = DefaultRoute(presentationStyle: .detents([.medium]), content: { nil })
        XCTAssertEqual(sut.presentationStyle, .detents([.medium]))
    }

    // MARK: - content closure

    func test_content_returnsProvidedView() {
        let label = Text("hello")
        let sut = DefaultRoute(presentationStyle: .push, content: { label.asAnyView() })
        XCTAssertNotNil(sut.content())
    }

    func test_content_returnsNilWhenClosureReturnsNil() {
        let sut = DefaultRoute(presentationStyle: .push, content: { nil })
        XCTAssertNil(sut.content())
    }

    // MARK: - SCIdentifiable default id

    func test_id_isDescriptionBased() {
        let sut = DefaultRoute(presentationStyle: .sheet, content: { nil })
        XCTAssertFalse(sut.id.isEmpty)
        XCTAssertTrue(sut.id.contains("DefaultRoute"))
    }

    // MARK: - SCEquatable

    func test_equality_sameInstance() {
        let sut = DefaultRoute(presentationStyle: .sheet, content: { nil })
        XCTAssertEqual(sut, sut)
    }

    func test_equality_samePresentationStyle_equalDescriptions() {
        let a = DefaultRoute(presentationStyle: .push, content: { nil })
        let b = DefaultRoute(presentationStyle: .push, content: { nil })
        XCTAssertEqual(a.id, b.id)
        XCTAssertEqual(a, b)
    }

    func test_inequality_differentPresentationStyles() {
        let a = DefaultRoute(presentationStyle: .push, content: { nil })
        let b = DefaultRoute(presentationStyle: .sheet, content: { nil })
        XCTAssertNotEqual(a, b)
    }
}
