//
//  File.swift
//  
//
//  Created by Andres Lozano on 18/01/24.
//

import XCTest
import SwiftUI
@testable import SUICoordinator


final class RouterTests: XCTestCase {
    
    func test_navigationStack_pushToRoute() throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.pushStep
        
        try execute { sut.navigate(to: route, animated: false, completion: $0) }
        
        XCTAssertEqual(sut.items.last, route)
    }
    
    func test_navigationStack_pop() throws {
        let sut = makeSUT()
        
        try execute { sut.navigate(to: .pushStep, animated: false,completion: $0) }
        try execute { sut.pop(animated: false, completion: $0) }
        
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertNil(sut.items.last ?? nil)
    }
    
    func test_navigationStack_popToRoot() throws {
        let sut = makeSUT()
        
        try execute { sut.navigate(to: .pushStep, animated: false, completion: $0) }
        try execute { sut.navigate(to: .pushStep2, animated: false, completion: $0) }
        try execute { sut.navigate(to: .pushStep3, animated: false, completion: $0) }
        try execute { sut.popToRoot(animated: false, completion: $0) }
        
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertNil(sut.items.last ?? nil)
    }
    
    func test_sheetStack_presentRoute() throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.sheetStep
        
        try execute { sut.navigate(to: route, animated: false, completion: $0) }
        
        XCTAssertFalse(sut.sheetCoordinator.items.isEmpty)
        XCTAssertNotNil(sut.sheetCoordinator.items.last ?? nil)
    }
    
    func test_sheetStack_presentRouteTwice() throws {
        let sut = makeSUT()
        let finalRoute = AnyEnumRoute.sheetStep
        
        try execute { sut.navigate(to: .sheetStep, animated: false, completion: $0) }
        try execute { sut.navigate(to: finalRoute, animated: false, completion: $0) }
        
        XCTAssertEqual(sut.sheetCoordinator.items.count, 2)
        XCTAssertNotNil(sut.sheetCoordinator.items.last ?? nil)
    }
    
    func test_sheetStack_dismissRoute() throws {
        let sut = makeSUT()
        
        try execute { sut.navigate(to: .sheetStep, animated: false, completion: $0) }
        XCTAssertEqual(sut.sheetCoordinator.items.count, 1)
        
        try execute { sut.dismiss(animated: false, completion: $0) }
        XCTAssertEqual(sut.sheetCoordinator.items.count, 0)
    }
    
    func test_closeRoute() throws {
        let sut = makeSUT()
        
        try execute { sut.navigate(to: .pushStep, animated: false, completion: $0) }
        try execute { sut.close(animated: false, completion: $0) }
        XCTAssertEqual(sut.items.count, 0)
        
        try execute { sut.navigate(to: .sheetStep, animated: false, completion: $0) }
        try execute { sut.close(animated: false, completion: $0) }
        XCTAssertEqual(sut.sheetCoordinator.items.count, 0)
    }
    
    func test_cleanRouter() throws {
        let sut = makeSUT()
        
        try execute { sut.navigate(to: .pushStep, animated: false, completion: $0) }
        try execute { sut.navigate(to: .pushStep2, animated: false, completion: $0) }
        try execute { sut.navigate(to: .sheetStep, animated: false, completion: $0) }
        try execute { sut.navigate(to: .fullScreenStep, animated: false, completion: $0) }
        try execute { sut.clean(animated: false, completion: $0) }
        
        XCTAssertEqual(sut.items.count, 0)
        XCTAssertEqual(sut.sheetCoordinator.items.count, 0)
        XCTAssertNil(sut.mainView)
    }
    
    func test_navigationStack_popToView() throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.pushStep
        
        try execute { sut.navigate(to: route, animated: false, completion: $0) }
        try execute { sut.navigate(to: .pushStep2, animated: false, completion: $0) }
        try execute { sut.navigate(to: .pushStep3, animated: false, completion: $0) }
        
        try execute { completion in
            sut.popToView(route, animated: false) { result in
                XCTAssertTrue(result)
                completion?()
            }
        }
        
        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.items.last?.id, route.id)
    }
    
    func test_navigationStack_popToViewFail() throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.fullScreenStep
        
        try execute { sut.navigate(to: .pushStep, animated: false, completion: $0) }
        try execute { sut.navigate(to: .pushStep2, animated: false, completion: $0) }
        try execute { sut.navigate(to: .pushStep3, animated: false, completion: $0) }
        
        try execute { completion in
            sut.popToView(route, animated: false) { result in
                XCTAssertFalse(result)
                completion?()
            }
        }
        
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
