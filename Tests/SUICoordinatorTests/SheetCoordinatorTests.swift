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

@available(iOS 17.0, *)
@MainActor
final class SheetCoordinatorTests: XCTestCase {
    
    func test_presentRoute() async throws {
        let sut = makeSUT()
        let item = makeSheetItem("Custom Item")
        
        await sut.presentSheet(item)
        
        XCTAssertFalse(sut.items.isEmpty)
        XCTAssertEqual(item.getPresentationStyle(), .sheet)
        XCTAssertEqual(item.isAnimated(), false)
        XCTAssertEqual(sut.items.last??.view(), item.view())
    }
    
    func test_presentRouteTwice() async throws {
        let sut = makeSUT()
        let finalRoute = makeSheetItem("Final Item")
        
        await presentSheet(makeSheetItem("First Item"), with: sut)
        await presentSheet(finalRoute, with: sut)
        
        XCTAssertEqual(sut.items.count, 2)
        XCTAssertEqual(sut.items.last??.id, finalRoute.id)
    }
    
    func test_dismiss_lastRoute() async throws {
        let sut = makeSUT()
        let item = makeSheetItem("Custom Item")
        
        await presentSheet(item, with: sut)
        XCTAssertEqual(sut.items.count, 1)
        
        await sut.removeLastSheet(animated: false)
        await sut.removeAllNilItems()
        
        XCTAssertEqual(sut.items.count, 0)
    }
    
    func test_dismiss_lastRouteCoordinator() async throws {
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
    
    func test_dismiss_route_atPositon() async throws {
        let sut = makeSUT()
        
        await presentSheet(makeSheetItem("First Item"), with: sut)
        await presentSheet(makeSheetItem("Second Item", isCoordinator: true), with: sut)
        await presentSheet(makeSheetItem("Third Item"), with: sut)
        await sut.remove(at: "\(1)")
        
        XCTAssertEqual(sut.items.count, 2)
        XCTAssertEqual(sut.items.last??.view(), "Third Item")
    }
    
    func test_calculation_of_index() async throws {
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
    
    func test_cleanCoordinator() async throws {
        let sut = makeSUT()

        await presentSheet(makeSheetItem("First Item", presentationStyle: .fullScreenCover), with: sut)
        await presentSheet(makeSheetItem("Second Item"), with: sut)
        await presentSheet(makeSheetItem("Third Item"), with: sut)
        XCTAssertEqual(sut.items.count, 3)

        await sut.clean(animated: false)
        XCTAssertNil(sut.items.first??.view)
    }

    // MARK: - lastPresentationStyle

    func test_lastPresentationStyle_nilOnFreshCoordinator() {
        let sut = makeSUT()
        XCTAssertNil(sut.lastPresentationStyle)
    }

    func test_lastPresentationStyle_updatesAfterPresent() async {
        let sut = makeSUT()
        await presentSheet(makeSheetItem("Item", presentationStyle: .fullScreenCover), with: sut)
        XCTAssertEqual(sut.lastPresentationStyle, .fullScreenCover)
    }

    // MARK: - animated

    func test_animated_nilOnFreshCoordinator() {
        let sut = makeSUT()
        XCTAssertNil(sut.animated)
    }

    func test_animated_updatesAfterPresent() async {
        let sut = makeSUT()
        let item = makeSheetItem("Item", animated: true)
        await presentSheet(item, with: sut)
        XCTAssertEqual(sut.animated, true)
    }

    // MARK: - areEmptyItems

    func test_areEmptyItems_trueWhenEmpty() async {
        let sut = makeSUT()
        let isEmpty = await sut.areEmptyItems
        XCTAssertTrue(isEmpty)
    }

    func test_areEmptyItems_falseAfterPresent() async {
        let sut = makeSUT()
        await presentSheet(makeSheetItem("Item"), with: sut)
        let isEmpty = await sut.areEmptyItems
        XCTAssertFalse(isEmpty)
    }

    // MARK: - removeSheet(at:animated:)

    func test_removeSheet_atIndex_nilsTheEntry() async {
        let sut = makeSUT()
        await presentSheet(makeSheetItem("Item"), with: sut)
        XCTAssertEqual(sut.items.count, 1)

        await sut.removeSheet(at: [0], animated: false)
        XCTAssertNil(sut.items.first ?? nil)
    }

    func test_removeSheet_multipleIndexes() async {
        let sut = makeSUT()
        await presentSheet(makeSheetItem("First"), with: sut)
        await presentSheet(makeSheetItem("Second"), with: sut)
        await presentSheet(makeSheetItem("Third"), with: sut)

        await sut.removeSheet(at: [1], animated: false)
        XCTAssertNil(sut.items[1])
    }

    // MARK: - onRemoveItem callback

    func test_onRemoveItem_calledOnRemove() async {
        let sut = makeSUT()
        var receivedId: String?
        sut.onRemoveItem = { id in receivedId = id }

        await presentSheet(makeSheetItem("Item", isCoordinator: true), with: sut)
        await sut.remove(at: "0")

        XCTAssertNotNil(receivedId)
    }

    // MARK: - removeCustomSheets

    func test_removeCustomSheets_cleansUpCustomSheetsAboveRemovedIndex() async {
        let sut = makeSUT()
        let customItem = makeSheetItem(
            "Custom",
            presentationStyle: .custom(transition: .move(edge: .bottom), animation: .default, fullScreen: false)
        )

        await presentSheet(makeSheetItem("Sheet"), with: sut)      // index 0 — plain sheet
        await presentSheet(customItem, with: sut)                   // index 1 — custom (orphan candidate)

        // Removing index 0 should also clean up the custom sheet at index 1
        await sut.remove(at: "0")

        XCTAssertTrue(sut.items.isEmpty)
    }

    func test_removeCustomSheets_doesNotRemoveNonCustomSheetsAbove() async {
        let sut = makeSUT()

        await presentSheet(makeSheetItem("First"), with: sut)       // index 0
        await presentSheet(makeSheetItem("Second"), with: sut)      // index 1 — plain sheet, should survive

        await sut.remove(at: "0")

        // Non-custom sheet above is not cleaned up by removeCustomSheets
        XCTAssertEqual(sut.items.count, 1)
    }

    // MARK: - handleRemove / getBackupItemIndex

    func test_handleRemove_firesOnRemoveItem_forCoordinatorItemsAboveRemovedIndex() async {
        let sut = makeSUT()
        var receivedIds: [String] = []
        sut.onRemoveItem = { id in receivedIds.append(id) }

        // handleRemove scans from nextIndex (index+1) onwards after the removed item is compacted out.
        // Need 3 items: remove index 1 → nextIndex=2 → after remove+compact, item originally at index 2
        // is now at index 1, which handleRemove(index:2) would scan — but we need the coordinator at
        // original index 2 to still be at index 2 after removal of index 1 (no compaction mid-scan).
        // Simplest: 3 items, remove index 0 → nextIndex=1, after compact item[1]→[0], item[2]→[1].
        // handleRemove(index:1) scans index 1 (original index 2).
        let coordinatorItem = makeSheetItem("Coordinator", presentationStyle: .sheet, isCoordinator: true)

        await presentSheet(makeSheetItem("First"), with: sut)       // index 0 — removed
        await presentSheet(makeSheetItem("Second"), with: sut)      // index 1 — shifts to 0 after removal
        await presentSheet(coordinatorItem, with: sut)              // index 2 — shifts to 1, scanned by handleRemove

        await sut.remove(at: "0")

        XCTAssertTrue(receivedIds.contains(coordinatorItem.id))
    }

    func test_handleRemove_doesNotFireCallback_forNonCoordinatorItemsAbove() async {
        let sut = makeSUT()
        var receivedIds: [String] = []
        sut.onRemoveItem = { id in receivedIds.append(id) }

        let firstItem = makeSheetItem("First")
        let secondItem = makeSheetItem("Second")   // plain, no coordinator
        let thirdItem  = makeSheetItem("Third")    // plain, no coordinator

        await presentSheet(firstItem, with: sut)
        await presentSheet(secondItem, with: sut)
        await presentSheet(thirdItem, with: sut)

        // Remove index 0; handleRemove scans above but finds no coordinator items → no extra callbacks
        await sut.remove(at: "0")

        // onRemoveItem fires for the removed item itself (backUpItems entry for index 0),
        // but NOT for the non-coordinator items above via handleRemove
        XCTAssertEqual(receivedIds.count, 1)
        XCTAssertEqual(receivedIds.first, firstItem.id)
    }

    // MARK: - Edge cases

    func test_remove_at_invalidIndex_doesNotCrash() async {
        let sut = makeSUT()
        await sut.remove(at: "99") // nothing to remove
        XCTAssertTrue(sut.items.isEmpty)
    }

    func test_remove_at_nonNumericString_doesNotCrash() async {
        let sut = makeSUT()
        await sut.remove(at: "not_a_number")
        XCTAssertTrue(sut.items.isEmpty)
    }

    func test_removeLastSheet_onEmpty_doesNotCrash() async {
        let sut = makeSUT()
        await sut.removeLastSheet(animated: false) // nothing to remove
        XCTAssertTrue(sut.items.isEmpty)
    }

    func test_presentMultiple_removeAtIndex_callbackFiredForEach() async {
        let sut = makeSUT()
        var receivedIds: [String] = []
        sut.onRemoveItem = { id in receivedIds.append(id) }

        let first = makeSheetItem("First", isCoordinator: true)
        let second = makeSheetItem("Second", isCoordinator: true)
        await presentSheet(first, with: sut)
        await presentSheet(second, with: sut)

        // Remove both items sequentially; after each removal the array compacts
        await sut.remove(at: "1")
        await sut.remove(at: "0")

        XCTAssertEqual(receivedIds.count, 2)
    }

    // --------------------------------------------------------------------
    // MARK: Helpers
    // --------------------------------------------------------------------
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> SheetCoordinator<String> {
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
    
    private func presentSheet( _ item: SheetItem<String>, with sut: SheetCoordinator<String>) async {
        await sut.presentSheet(item)
    }
}

import Combine
