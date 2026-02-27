//
//  ItemManagerTests.swift
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

final class ItemManagerTests: XCTestCase {

    // MARK: - addItem / getAllItems

    func test_addItem_appendsToCollection() async {
        let sut = ItemManager<Int>()
        await sut.addItem(1)
        await sut.addItem(2)
        let items = await sut.getAllItems()
        XCTAssertEqual(items, [1, 2])
    }

    // MARK: - setItems

    func test_setItems_replacesCollection() async {
        let sut = ItemManager<Int>()
        await sut.addItem(99)
        await sut.setItems([1, 2, 3])
        let items = await sut.getAllItems()
        XCTAssertEqual(items, [1, 2, 3])
    }

    // MARK: - totalItems

    func test_totalItems_returnsLastIndex() async {
        let sut = ItemManager<String>()
        let total = await sut.totalItems
        XCTAssertEqual(total, 0, "Empty collection should return 0")

        await sut.addItem("a")
        await sut.addItem("b")
        await sut.addItem("c")
        let totalAfter = await sut.totalItems
        XCTAssertEqual(totalAfter, 2, "totalItems is count - 1 (last valid index)")
    }

    // MARK: - areItemsEmpty

    func test_areItemsEmpty_trueWhenEmpty() async {
        let sut = ItemManager<Int>()
        let empty = await sut.areItemsEmpty()
        XCTAssertTrue(empty)
    }

    func test_areItemsEmpty_falseAfterAdd() async {
        let sut = ItemManager<Int>()
        await sut.addItem(1)
        let empty = await sut.areItemsEmpty()
        XCTAssertFalse(empty)
    }

    // MARK: - isValid(index:)

    func test_isValid_trueForExistingIndex() async {
        let sut = ItemManager<Int>()
        await sut.addItem(10)
        let valid = await sut.isValid(index: 0)
        XCTAssertTrue(valid)
    }

    func test_isValid_falseForOutOfBoundsIndex() async {
        let sut = ItemManager<Int>()
        let valid = await sut.isValid(index: 5)
        XCTAssertFalse(valid)
    }

    // MARK: - removeItem(at:)

    func test_removeItem_returnsRemovedElement() async {
        let sut = ItemManager<String>()
        await sut.addItem("first")
        await sut.addItem("second")
        let removed = await sut.removeItem(at: 0)
        XCTAssertEqual(removed, "first")
        let remaining = await sut.getAllItems()
        XCTAssertEqual(remaining, ["second"])
    }

    func test_removeItem_returnsNilForInvalidIndex() async {
        let sut = ItemManager<String>()
        let removed = await sut.removeItem(at: 99)
        XCTAssertNil(removed)
    }

    // MARK: - removeLastItem

    func test_removeLastItem_returnsAndRemovesLast() async {
        let sut = ItemManager<Int>()
        await sut.addItem(1)
        await sut.addItem(2)
        let last = await sut.removeLastItem()
        XCTAssertEqual(last, 2)
        let remaining = await sut.getAllItems()
        XCTAssertEqual(remaining, [1])
    }

    func test_removeLastItem_returnsNilWhenEmpty() async {
        let sut = ItemManager<Int>()
        let last = await sut.removeLastItem()
        XCTAssertNil(last)
    }

    // MARK: - removeAll

    func test_removeAll_clearsCollection() async {
        let sut = ItemManager<Int>()
        await sut.addItem(1)
        await sut.addItem(2)
        await sut.removeAll()
        let items = await sut.getAllItems()
        XCTAssertTrue(items.isEmpty)
    }

    func test_removeAll_onEmptyCollection_doesNotCrash() async {
        let sut = ItemManager<Int>()
        await sut.removeAll() // should not throw or crash
        let items = await sut.getAllItems()
        XCTAssertTrue(items.isEmpty)
    }

    // MARK: - getItem(at:) — Optional extension

    func test_getItem_unwrapsOptionalValue() async {
        let sut = ItemManager<Int?>()
        await sut.addItem(42)
        await sut.addItem(nil)
        let first = await sut.getItem(at: 0)
        XCTAssertEqual(first, 42)
        let second = await sut.getItem(at: 1)
        XCTAssertNil(second)
    }

    func test_getItem_returnsNilForInvalidIndex() async {
        let sut = ItemManager<Int?>()
        let item = await sut.getItem(at: 99)
        XCTAssertNil(item)
    }

    // MARK: - makeItemsNil(at:) — Array version

    func test_makeItemsNil_array_setsIndexesToNil() async {
        let sut = ItemManager<Int?>()
        await sut.addItem(1)
        await sut.addItem(2)
        await sut.addItem(3)
        await sut.makeItemsNil(at: [0, 2])
        let items = await sut.getAllItems()
        XCTAssertNil(items[0])
        XCTAssertEqual(items[1], 2)
        XCTAssertNil(items[2])
    }

    func test_makeItemsNil_array_ignoresInvalidIndexes() async {
        let sut = ItemManager<Int?>()
        await sut.addItem(1)
        await sut.makeItemsNil(at: [0, 99]) // 99 is invalid, should not crash
        let items = await sut.getAllItems()
        XCTAssertNil(items[0])
    }

    // MARK: - makeItemsNil(at:) — Variadic version

    func test_makeItemsNil_variadic_setsIndexesToNil() async {
        let sut = ItemManager<String?>()
        await sut.addItem("a")
        await sut.addItem("b")
        await sut.makeItemsNil(at: 0, 1)
        let items = await sut.getAllItems()
        XCTAssertNil(items[0])
        XCTAssertNil(items[1])
    }

    // MARK: - removeAllNilItems

    func test_removeAllNilItems_removesOnlyNilEntries() async {
        let sut = ItemManager<Int?>()
        await sut.addItem(1)
        await sut.addItem(nil)
        await sut.addItem(3)
        await sut.addItem(nil)
        await sut.removeAllNilItems()
        let items = await sut.getAllItems()
        XCTAssertEqual(items.compactMap { $0 }, [1, 3])
    }
}
