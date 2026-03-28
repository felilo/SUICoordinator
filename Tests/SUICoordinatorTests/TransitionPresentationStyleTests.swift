//
//  TransitionPresentationStyleTests.swift
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
final class TransitionPresentationStyleTests: XCTestCase {

    // MARK: - isCustom

    func test_isCustom_trueForCustomCase() {
        let style = TransitionPresentationStyle.custom(transition: .opacity, animation: nil)
        XCTAssertTrue(style.isCustom)
    }

    func test_isCustom_falseForNonCustomCases() {
        XCTAssertFalse(TransitionPresentationStyle.push.isCustom)
        XCTAssertFalse(TransitionPresentationStyle.sheet.isCustom)
        XCTAssertFalse(TransitionPresentationStyle.fullScreenCover.isCustom)
        XCTAssertFalse(TransitionPresentationStyle.detents([.medium]).isCustom)
    }

    // MARK: - Equatability

    func test_equality_sameSimpleCases() {
        XCTAssertEqual(TransitionPresentationStyle.push, .push)
        XCTAssertEqual(TransitionPresentationStyle.sheet, .sheet)
        XCTAssertEqual(TransitionPresentationStyle.fullScreenCover, .fullScreenCover)
    }

    func test_equality_detentsCases() {
        // Equality is id-based (String(describing:self)). Use a single detent to avoid
        // non-deterministic Set ordering in the description string.
        let a = TransitionPresentationStyle.detents([.medium])
        let b = TransitionPresentationStyle.detents([.medium])
        XCTAssertEqual(a, b)
    }

    func test_inequality_differentCases() {
        XCTAssertNotEqual(TransitionPresentationStyle.push, .sheet)
        XCTAssertNotEqual(TransitionPresentationStyle.sheet, .fullScreenCover)
        XCTAssertNotEqual(TransitionPresentationStyle.detents([.medium]), .sheet)
    }

    // MARK: - SCHashable / SCIdentifiable

    func test_id_isUniquePerCase() {
        let push = TransitionPresentationStyle.push
        let sheet = TransitionPresentationStyle.sheet
        // id is derived from String(describing:self), so same case = same id
        XCTAssertEqual(push.id, TransitionPresentationStyle.push.id)
        XCTAssertNotEqual(push.id, sheet.id)
    }

    // MARK: - DefaultRoute

    func test_defaultRoute_presentationStyle() {
        let style = TransitionPresentationStyle.sheet
        let route = DefaultRoute(presentationStyle: style, content: { nil })
        XCTAssertEqual(route.presentationStyle, style)
    }

    func test_defaultRoute_viewIsNilWhenContentReturnsNil() {
        let route = DefaultRoute(presentationStyle: .push, content: { nil })
        XCTAssertNil(route.content())
    }
}
