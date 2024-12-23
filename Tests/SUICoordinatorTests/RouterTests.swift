//
//  RouterTests.swift
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


final class RouterTests: XCTestCase {
    
    @MainActor func test_navigationStack_pushToRoute() async throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.pushStep
        
        await sut.navigate(to: route, animated: false)
        
        XCTAssertEqual(sut.items.last?.id, route.id)
    }
    
    @MainActor func test_navigationStack_pop() async throws {
        let sut = makeSUT()
        
        await sut.navigate(to: .pushStep, animated: false)
        await sut.pop(animated: false)
        
        XCTAssertNil(sut.items.last ?? nil)
    }
    
    @MainActor func test_navigationStack_popToRoot() async throws {
        let sut = makeSUT()
        
        await sut.navigate(to: .pushStep, animated: false)
        await sut.navigate(to: .pushStep2, animated: false)
        await sut.navigate(to: .pushStep3, animated: false)
        await sut.popToRoot(animated: false)
        
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertNil(sut.items.last ?? nil)
    }
    
    @MainActor func test_closeRoute() async throws {
        let sut = makeSUT()
        
        await sut.navigate(to: .pushStep, animated: false)
        await sut.close(animated: false)
        XCTAssertEqual(sut.items.count, 0)
        
        await sut.navigate(to: .sheetStep, animated: false)
        await sut.close(animated: false)
        sut.sheetCoordinator.removeAllNilItems()
        XCTAssertEqual(sut.sheetCoordinator.items.count, 0)
    }
    
    @MainActor func test_cleanRouter() async throws {
        let sut = makeSUT()
        
        await sut.navigate(to: .pushStep, animated: false)
        await sut.navigate(to: .pushStep2, animated: false)
        await sut.navigate(to: .sheetStep, animated: false)
        await sut.navigate(to: .fullScreenStep, animated: false)
        await sut.clean(animated: false)
        await sut.restart(animated: false)
        
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertEqual(sut.sheetCoordinator.items.count, 0)
    }
    
    @MainActor func test_restartRouter() async throws {
        let sut = makeSUT()
        
        await sut.navigate(to: .pushStep, animated: false)
        await sut.navigate(to: .pushStep2, animated: false)
        await sut.navigate(to: .sheetStep, animated: false)
        await sut.present(.fullScreenStep)
        await sut.restart(animated: false)
        
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertEqual(sut.sheetCoordinator.items.count, 0)
        XCTAssertNotNil(sut.mainView)
    }
    
    @MainActor func test_presentItem_with_presentationStyle_not_valid() async throws {
        let sut = makeSUT()
        
        await sut.present(.sheetStep, presentationStyle: .push, animated: false)
        
        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.sheetCoordinator.items.count, 0)
    }
    
    @MainActor func test_presentItem_with_presentationStyle_valid() async throws {
        let sut = makeSUT()
        
        await sut.present(.sheetStep, presentationStyle: .sheet, animated: false)
        
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertEqual(sut.sheetCoordinator.items.count, 1)
    }
    
    @MainActor func test_navigationStack_popToView() async throws {
        let sut = makeSUT()
        let view = PushStepView.self
        
        await sut.navigate(to: .pushStep, animated: false)
        await sut.navigate(to: .pushStep2, animated: false)
        await sut.navigate(to: .pushStep3, animated: false)
        
        let result = await sut.popToView(view, animated: false)
        XCTAssertTrue(result)
        
        XCTAssertEqual(sut.items.count, 1)
        if let lastItem = sut.items.last {
            XCTAssertEqual(getNameOf(object: lastItem.view), getNameOf(object: view))
        } else {
            XCTFail("lastItem can not be nil")
        }
    }
    
    @MainActor func test_navigationStack_popToView_with_customRoute() async throws {
        let sut = Router<DefaultRoute>()
        let view = PushStepView.self
        sut.mainView = DefaultRoute(presentationStyle: .push, content: { PushStepView() })
        
        await sut.navigate(to: .init(presentationStyle: .push, content: { PushStepView() } ), animated: false)
        await sut.navigate(to: .init(presentationStyle: .push, content: { PushStep2View() } ), animated: false)
        await sut.navigate(to: .init(presentationStyle: .push, content: { PushStep3View() } ), animated: false)
        await sut.navigate(to: .init(presentationStyle: .push, content: { FullScreenStepView() } ), animated: false)
        
        let result = await sut.popToView(view, animated: false)
        
        XCTAssertTrue(result)
        XCTAssertEqual(sut.items.count, 1)
        
        if let lastItem = sut.items.last {
            XCTAssertEqual(getNameOf(object: lastItem.view), getNameOf(object: view))
            XCTAssertEqual(lastItem.presentationStyle, .push)
        } else {
            XCTFail("lastItem can not be nil")
        }
    }
    
    @MainActor func test_navigationStack_popToViewFail() async throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.fullScreenStep
        
        await sut.navigate(to: .pushStep, animated: false)
        await sut.navigate(to: .pushStep2, animated: false)
        await sut.navigate(to: .pushStep3, animated: false)
        
        let result = await sut.popToView(route, animated: false)
        XCTAssertFalse(result)
        
        XCTAssertEqual(sut.items.count, 3)
    }
    
    @MainActor func test_dissmiss_sheet_swipedAway() async throws {
        let sut = makeSUT()
        let index = 0
        
        await sut.navigate(to: .pushStep, presentationStyle: .sheet, animated: false)
        
        XCTAssertEqual(sut.sheetCoordinator.items.count, 1)
        
        sut.removeNilItemsFromSheetCoordinator()
        sut.removeItemFromSheetCoordinator(at: index)
        
        XCTAssertEqual(sut.sheetCoordinator.items.count, 0)
    }
    
    // --------------------------------------------------------------------
    // MARK: Helpers
    // --------------------------------------------------------------------
    
    @MainActor private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> Router<AnyEnumRoute> {
        let router = Router<AnyEnumRoute>()
        router.mainView = .pushStep
        trackForMemoryLeaks(router, file: file, line: line)
        return router
    }
    
    @MainActor private func makeSheetItem(_ item: any RouteType, animated: Bool = true) -> SheetItem<RouteType.Body> {
        .init(id: UUID().uuidString, animated: animated, presentationStyle: item.presentationStyle, view: { item.view })
    }
}
