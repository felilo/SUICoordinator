//
//  SheetCoordinatorTests.swift
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
@testable import SUICoordinator

final class SheetCoordinatorTests: XCTestCase {
    
    @MainActor func test_presentRoute() async throws {
        let sut = makeSUT()
        let item = makeSheetItem("Custom Item")
        
        await sut.presentSheet(item)
        
        XCTAssertFalse(sut.items.isEmpty)
        XCTAssertEqual(item.getPresentationStyle(), .sheet)
        XCTAssertEqual(item.isAnimated(), false)
        XCTAssertEqual(sut.items.last??.view(), item.view())
    }
    
    @MainActor func test_presentRouteTwice() async throws {
        let sut = makeSUT()
        let finalRoute = makeSheetItem("Final Item")
        
        await presentSheet(makeSheetItem("First Item"), with: sut)
        await presentSheet(finalRoute, with: sut)
        
        XCTAssertEqual(sut.items.count, 2)
        XCTAssertEqual(sut.items.last??.id, finalRoute.id)
    }
    
    @MainActor func test_dismiss_lastRoute() async throws {
        let sut = makeSUT()
        let item = makeSheetItem("Custom Item")
        
        await presentSheet(item, with: sut)
        XCTAssertEqual(sut.items.count, 1)
        
        await sut.removeLastSheet(animated: false)
        await sut.removeAllNilItems()
        
        XCTAssertEqual(sut.items.count, 0)
    }
    
    @MainActor func test_dismiss_lastRouteCoordinator() async throws {
        let sut = makeSUT()
        let item = makeSheetItem("Custom Item", presentationStyle: .custom(transition: .move(edge: .bottom), animation: .default, fullScreen: false))
        
        await presentSheet(item, with: sut)
        XCTAssertEqual(sut.items.count, 1)
        var willDismissAsync = asyncStream(item.willDismiss).makeAsyncIterator()
        
        await sut.removeLastSheet(animated: false)
        let event: Void? = await willDismissAsync.next()
        
        XCTAssertNotNil(event)
        
        await sut.remove(at: "0")
        
        XCTAssertEqual(sut.items.count, 0)
    }
    
    @MainActor func test_dismiss_route_atPositon() async throws {
        let sut = makeSUT()
        
        await presentSheet(makeSheetItem("First Item"), with: sut)
        await presentSheet(makeSheetItem("Second Item", isCoordinator: true), with: sut)
        await presentSheet(makeSheetItem("Third Item"), with: sut)
        await sut.remove(at: "\(1)")
        
        XCTAssertEqual(sut.items.count, 2)
        XCTAssertEqual(sut.items.last??.view(), "Third Item")
    }
    
    @MainActor func test_calculation_of_index() async throws {
        let sut = makeSUT()
        let iterations = 5
        
        XCTAssertTrue(sut.isLastIndex(iterations))
        
        for index in 0..<iterations {
            XCTAssertEqual(sut.getNextIndex(index), index + 1)
            await presentSheet(makeSheetItem("Item \(index)"), with: sut)
            XCTAssertTrue(sut.isLastIndex(index))
        }
        
        XCTAssertTrue(sut.isLastIndex(iterations - 1))
    }
    
    @MainActor func test_cleanCoordinator() async throws {
        let sut = makeSUT()
        
        await presentSheet(makeSheetItem("First Item", presentationStyle: .fullScreenCover), with: sut)
        await presentSheet(makeSheetItem("Second Item"), with: sut)
        await presentSheet(makeSheetItem("Third Item"), with: sut)
        XCTAssertEqual(sut.items.count, 3)
        
        await sut.clean(animated: false)
        XCTAssertNil(sut.items.first??.view)
    }
    
    // --------------------------------------------------------------------
    // MARK: Helpers
    // --------------------------------------------------------------------
    
    @MainActor private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SheetCoordinator<String> {
        let coordinator = SheetCoordinator<String>()
        trackForMemoryLeaks(coordinator, file: file, line: line)
        return coordinator
    }
    
    private func makeSheetItem(
        _ item: String,
        presentationStyle: TransitionPresentationStyle = .sheet,
        animated: Bool = false,
        isCoordinator: Bool = false
    ) -> SheetItem<String> {
        .init(
            id: UUID().uuidString,
            animated: animated,
            presentationStyle: presentationStyle,
            isCoordinator: isCoordinator,
            view: { item }
        )
    }
    
    @MainActor private func presentSheet( _ item: SheetItem<String>, with sut: SheetCoordinator<String>) async {
        await sut.presentSheet(item)
    }
}

import Combine
