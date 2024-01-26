//
//  File.swift
//  
//
//  Created by Andres Lozano on 18/01/24.
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
