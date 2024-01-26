//
//  CoordinatorTests.swift
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

final class CoordinatorTests: XCTestCase {
    
    func test_restartMainCoordinator() throws {
        let sut = makeSUT()
        let coordinator1 = OtherCoordinator()
        let coordinator2 = AnyCoordinator()
        
        try execute { sut.start(animated: false, completion: $0)}
        try execute { sut.router.navigate(to: .pushStep, animated: false, completion: $0) }
        try startCoordinator(coordinator1, parent: sut)
        try startCoordinator(coordinator2, parent: coordinator1)
        try execute { sut.router.restart(animated: false, completion: $0) }
        
        XCTAssertEqual(sut.router.items.count, 0)
        XCTAssertTrue(sut.children.isEmpty)
        XCTAssertNotNil(sut.router.mainView)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
        try finishFlow(sut: sut)
    }
    
    func test_finshFlow() throws {
        let sut = makeSUT()
        
        try execute { sut.start(animated: false, completion: $0)}
        try execute { sut.router.navigate(to: .pushStep2, animated: false, completion: $0) }
        try execute { sut.router.navigate(to: .sheetStep, animated: false, completion: $0) }
        
        try finishFlow(sut: sut)
        XCTAssertEqual(sut.router.items.count, 0)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
    }
    
    func test_finshFlow_mainCoordinator() throws {
        let sut = AnyCoordinator()
        let coordinator = OtherCoordinator()
        
        try execute { sut.start(animated: false, completion: $0)}
        try execute { sut.router.navigate(to: .pushStep2, animated: false, completion: $0) }
        try startCoordinator(coordinator, parent: sut)
        try execute { sut.router.navigate(to: .sheetStep, animated: false, completion: $0) }
        
        try finishFlow(sut: sut)
        XCTAssertEqual(sut.router.items.count, 0)
        XCTAssertNotNil(sut.router.mainView)
        XCTAssertTrue(sut.children.isEmpty)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
    }
    
    func test_starFlow() throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.fullScreenStep
        
        try execute { sut.start(animated: false, completion: $0)}
        try execute {
            sut.startFlow(route: route)
            $0?()
        }
        
        XCTAssertEqual(sut.router.mainView, route)
        try finishFlow(sut: sut)
    }
    
    func test_navigateToCoordinator() throws {
        let sut = makeSUT()
        let coordinator = OtherCoordinator()
        
        try execute { sut.start(animated: false, completion: $0)}
        try startCoordinator(coordinator, parent: sut)
        
        XCTAssertEqual(sut.children.last?.id, coordinator.id)
        XCTAssertEqual(sut.uuid, coordinator.parent.uuid)
        try finishFlow(sut: sut)
    }
    
    func test_getTopmostCoordinator() throws {
        let sut = makeSUT()
        let coordinator1 = OtherCoordinator()
        let coordinator2 = AnyCoordinator()
        
        try execute { sut.start(animated: false, completion: $0)}
        try startCoordinator(coordinator1, parent: sut)
        try startCoordinator(coordinator2, parent: coordinator1)
        
        XCTAssertEqual(try sut.topCoordinator()?.uuid, coordinator2.uuid)
        try finishFlow(sut: sut)
    }
    
    func test_force_to_present_coordinator() throws {
        let sut = makeSUT()
        let coordinator1 = OtherCoordinator()
        let coordinator2 = AnyCoordinator()
        
        try execute { sut.start(animated: false, completion: $0)}
        try startCoordinator(coordinator1, parent: sut)
        try execute {
            try coordinator2.forcePresentation(
                animated: false,
                presentationStyle: .fullScreenCover,
                mainCoordinator: sut,
                completion: $0)
        }
        try execute { coordinator2.start(animated: false, completion: $0)}
        
        XCTAssertEqual(coordinator2.parent?.uuid, coordinator1.uuid)
        try finishFlow(sut: sut)
    }
    
    func test_finishCoordinatorWhichHasChildren() throws {
        let sut = makeSUT()
        let coordinator1 = OtherCoordinator()
        let coordinator2 = AnyCoordinator()
        let coordinator3 = AnyTabbarCoordinator()
        
        try execute { sut.start(animated: false, completion: $0)}
        try startCoordinator(coordinator1, parent: sut)
        try startCoordinator(coordinator2, parent: coordinator1)
        try startCoordinator(coordinator3, parent: coordinator2)
        
        XCTAssertFalse(sut.children.isEmpty)
        try finishFlow(sut: sut)
        
        XCTAssertTrue(sut.children.isEmpty)
        XCTAssertTrue(sut.router.items.isEmpty)
        XCTAssertTrue(sut.router.sheetCoordinator.items.isEmpty)
    }
    
    
    // --------------------------------------------------------------------
    // MARK: Helpers
    // --------------------------------------------------------------------
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> AnyCoordinator {
        let parent = OtherCoordinator()
        let coordinator = AnyCoordinator()
        coordinator.parent = parent
        parent.children.append(coordinator)
        trackForMemoryLeaks(coordinator, file: file, line: line)
        return coordinator
    }
    
    private func startCoordinator(_ coordinator: (any CoordinatorType), parent: (any CoordinatorType)) throws {
        try navigateToCoordinator(coordinator, in: parent)
        try execute { coordinator.start(animated: false, completion: $0) }
    }
}
