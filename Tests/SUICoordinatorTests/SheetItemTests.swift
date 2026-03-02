//
//  SheetItemTests.swift
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
import Combine
@testable import SUICoordinator

final class SheetItemTests: XCTestCase {

    // MARK: - init / properties

    func test_init_setsAllProperties() {
        let id = "test-id"
        let style = TransitionPresentationStyle.sheet
        let sut = SheetItem<String>(id: id, animated: true, presentationStyle: style, isCoordinator: true, view: { "hello" })

        XCTAssertEqual(sut.id, id)
        XCTAssertTrue(sut.animated)
        XCTAssertEqual(sut.presentationStyle, style)
        XCTAssertTrue(sut.isCoordinator)
        XCTAssertEqual(sut.view(), "hello")
    }

    func test_init_defaultIsCoordinatorIsFalse() {
        let sut = SheetItem<String>(id: "x", animated: false, presentationStyle: .push, view: { nil })
        XCTAssertFalse(sut.isCoordinator)
    }

    // MARK: - getPresentationStyle

    func test_getPresentationStyle_returnsCorrectStyle() {
        let sut = SheetItem<String>(id: "x", animated: false, presentationStyle: .fullScreenCover, view: { nil })
        XCTAssertEqual(sut.getPresentationStyle(), .fullScreenCover)
    }

    // MARK: - isAnimated

    func test_isAnimated_returnsTrue() {
        let sut = SheetItem<String>(id: "x", animated: true, presentationStyle: .sheet, view: { nil })
        XCTAssertTrue(sut.isAnimated())
    }

    func test_isAnimated_returnsFalse() {
        let sut = SheetItem<String>(id: "x", animated: false, presentationStyle: .sheet, view: { nil })
        XCTAssertFalse(sut.isAnimated())
    }

    // MARK: - willDismiss PassthroughSubject

    func test_willDismiss_receivesEvent() {
        let sut = SheetItem<String>(id: "x", animated: false, presentationStyle: .sheet, view: { nil })
        var received = false
        let cancellable = sut.willDismiss.sink { received = true }

        sut.willDismiss.send()

        XCTAssertTrue(received)
        cancellable.cancel()
    }

    // MARK: - SCEquatable (equality based on id)

    func test_equality_sameId() {
        let a = SheetItem<String>(id: "same", animated: false, presentationStyle: .sheet, view: { nil })
        let b = SheetItem<String>(id: "same", animated: true, presentationStyle: .push, view: { nil })
        XCTAssertEqual(a, b)
    }

    func test_inequality_differentId() {
        let a = SheetItem<String>(id: "a", animated: false, presentationStyle: .sheet, view: { nil })
        let b = SheetItem<String>(id: "b", animated: false, presentationStyle: .sheet, view: { nil })
        XCTAssertNotEqual(a, b)
    }

    // MARK: - PageDataSource helpers

    @available(iOS 17.0, *)
    func test_sortedByPosition_ordersCorrectly() {
        let sorted = AnyEnumTabRoute.sortedByPosition()
        let positions = sorted.map { $0.position }
        XCTAssertEqual(positions, positions.sorted())
    }

    @available(iOS 17.0, *)
    func test_pageId_containsPositionAndTypeName() {
        let tab = AnyEnumTabRoute.tab1
        // pageId format: "TypeName_position_DataSourceType"
        XCTAssertTrue(tab.pageId.contains("\(tab.position)"))
        XCTAssertTrue(tab.pageId.contains("AnyEnumTabRoute"))
    }
}
