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
import SwiftUI
@testable import SUICoordinator


final class RouterTests: XCTestCase {
    
    func test_navigationStack_pushToRoute() async throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.pushStep
        
        await sut.navigate(to: route, animated: false)
        
        XCTAssertEqual(sut.items.last, route)
    }
    
    func test_navigationStack_pop() async throws {
        let sut = makeSUT()
        
        await sut.navigate(to: .pushStep, animated: false)
        await sut.pop(animated: false)
        
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertNil(sut.items.last ?? nil)
    }
    
    func test_navigationStack_popToRoot() async throws {
        let sut = makeSUT()
        
        await sut.navigate(to: .pushStep, animated: false)
        await sut.navigate(to: .pushStep2, animated: false)
        await sut.navigate(to: .pushStep3, animated: false)
        await sut.popToRoot(animated: false)
        
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertNil(sut.items.last ?? nil)
    }
    
    func test_sheetStack_presentRoute() async throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.sheetStep
        
        await sut.navigate(to: route, animated: false)
        
        XCTAssertFalse(sut.sheetCoordinator.items.isEmpty)
        XCTAssertNotNil(sut.sheetCoordinator.items.last ?? nil)
    }
    
    func test_sheetStack_presentRouteTwice() async throws {
        let sut = makeSUT()
        let finalRoute = AnyEnumRoute.sheetStep
        
        await sut.navigate(to: .sheetStep, animated: false)
        await sut.navigate(to: finalRoute, animated: false)
        
        XCTAssertEqual(sut.sheetCoordinator.items.count, 2)
        XCTAssertNotNil(sut.sheetCoordinator.items.last ?? nil)
    }
    
    func test_sheetStack_dismissRoute() async throws {
        let sut = makeSUT()
        
        await sut.navigate(to: .sheetStep, animated: false)
        XCTAssertEqual(sut.sheetCoordinator.items.count, 1)
        
        await sut.dismiss(animated: false)
        XCTAssertEqual(sut.sheetCoordinator.items.count, 0)
    }
    
    func test_closeRoute() async throws {
        let sut = makeSUT()
        
        await sut.navigate(to: .pushStep, animated: false)
        await sut.close(animated: false)
        XCTAssertEqual(sut.items.count, 0)
        
        await sut.navigate(to: .sheetStep, animated: false)
        await sut.close(animated: false)
        XCTAssertEqual(sut.sheetCoordinator.items.count, 0)
    }
    
    func test_cleanRouter() async throws {
        let sut = makeSUT()
        
        await sut.navigate(to: .pushStep, animated: false)
        await sut.navigate(to: .pushStep2, animated: false)
        await sut.navigate(to: .sheetStep, animated: false)
        await sut.navigate(to: .fullScreenStep, animated: false)
        await sut.clean(animated: false)
        
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertEqual(sut.sheetCoordinator.items.count, 0)
        XCTAssertNil(sut.mainView)
    }
    
    func test_navigationStack_popToView() async throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.pushStep
        
        await sut.navigate(to: route, animated: false)
        await sut.navigate(to: .pushStep2, animated: false)
        await sut.navigate(to: .pushStep3, animated: false)
        
        let result = await sut.popToView(route, animated: false)
        XCTAssertTrue(result)
        
        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.items.last?.id, route.id)
    }
    
    func test_navigationStack_popToViewFail() async throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.fullScreenStep
        
        await sut.navigate(to: .pushStep, animated: false)
        await sut.navigate(to: .pushStep2, animated: false)
        await sut.navigate(to: .pushStep3, animated: false)
        
        let result = await sut.popToView(route, animated: false)
        XCTAssertFalse(result)
        
        XCTAssertEqual(sut.items.count, 3)
    }
    
    // --------------------------------------------------------------------
    // MARK: Helpers
    // --------------------------------------------------------------------
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> Router<AnyEnumRoute> {
        let router = Router<AnyEnumRoute>()
        router.mainView = .pushStep
        trackForMemoryLeaks(router, file: file, line: line)
        return router
    }
    
    private func makeSheetItem(_ item: any RouteType, animated: Bool = true) -> SheetItem<RouteType.Body> {
        .init(view: item.view, animated: animated, presentationStyle: item.presentationStyle)
    }
}
