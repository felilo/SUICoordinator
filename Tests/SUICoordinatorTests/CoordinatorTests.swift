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
import Combine
@testable import SUICoordinator

final class CoordinatorTests: XCTestCase {
    
    private let animated: Bool = false
    
    @MainActor func test_finishFlow() async throws {
        let sut = makeSUT()
        
        await sut.router.navigate(toRoute: .pushStep2, animated: animated )
        await sut.router.navigate(toRoute: .sheetStep, animated: animated )
        
        await finishFlow(sut: sut)
        XCTAssertEqual(sut.router.items.count, 0)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
    }
    
    @MainActor func test_CleanCoordinator() async throws {
        let sut = makeSUT()
        
        await sut.router.navigate(toRoute: .pushStep2, animated: animated )
        await sut.router.navigate(toRoute: .sheetStep, animated: animated )
        
        await finishFlow(sut: sut)
        XCTAssertEqual(sut.router.items.count, 0)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
    }
    
    @MainActor func test_finishFlow_swipedAway() async throws {
        let sut = makeSUT()
        let anyCoordinator = AnyCoordinator()
        
        await sut.navigate(to: anyCoordinator, presentationStyle: .sheet)
        await sut.router.sheetCoordinator.remove(at: "\(0)")
        
        try await Task.sleep(for: .seconds(0.5))
        
        XCTAssertEqual(anyCoordinator.router.items.count, 0)
        XCTAssertEqual(anyCoordinator.router.sheetCoordinator.items.count, 0)
    }
    
    @MainActor func test_finishFlow_mainCoordinator() async throws {
        let sut = AnyCoordinator()
        let coordinator = OtherCoordinator()
        
        await sut.start()
        await sut.router.navigate(toRoute: .pushStep2, animated: animated )
        await navigateToCoordinator(coordinator, in: sut)
        
        await finishFlow(sut: sut)
        XCTAssertEqual(sut.router.items.count, 0)
        XCTAssertTrue(sut.children.isEmpty)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
    }
    
    @MainActor func test_finishFlow_childCoordinator() async throws {
        let coordinator = OtherCoordinator()
        let sut = makeSUT()
        
        await sut.start()
        await navigateToCoordinator(sut, in: coordinator)
        
        await finishFlow(sut: sut)
        XCTAssertEqual(sut.router.items.count, 0)
        XCTAssertTrue(sut.children.isEmpty)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
    }
    
    @MainActor func test_starFlow() async throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.fullScreenStep

        await sut.startFlow(route: route)
        let mainView = try XCTUnwrap(sut.router.mainView)
        
        XCTAssertEqual(mainView, route)
        XCTAssertTrue(sut.isRunning)
    }
    
    @MainActor func test_parentCoordinator_not_nil() async throws {
        let sut = makeSUT()
        let coordinator = OtherCoordinator()
        
        await navigateToCoordinator(coordinator, in: sut)
        
        XCTAssertEqual(coordinator.parent?.uuid, sut.uuid)
        await finishFlow(sut: sut)
    }
    
    @MainActor func test_navigateToCoordinator() async throws {
        let sut = makeSUT()
        let coordinator = OtherCoordinator()
        
        await navigateToCoordinator(coordinator, in: sut)
        
        XCTAssertEqual(sut.children.last?.id, coordinator.id)
        XCTAssertEqual(sut.uuid, coordinator.parent?.uuid)
        await finishFlow(sut: sut)
    }
    
    @MainActor func test_navigateToCoordinator_with_customTransition() async throws {
        let sut = makeSUT()
        let coordinator = OtherCoordinator()
        
        await navigateToCoordinator(coordinator, in: sut, presentationStyle: .push)
        
        XCTAssertEqual(sut.children.last?.id, coordinator.id)
        XCTAssertEqual(sut.uuid, coordinator.parent?.uuid)
        await finishFlow(sut: sut)
    }
    
    @MainActor func test_getTopmostCoordinator() async throws {
        let sut = makeSUT()
        let coordinator1 = OtherCoordinator()
        let coordinator2 = AnyCoordinator()
        
        await navigateToCoordinator(coordinator1, in: sut)
        await navigateToCoordinator(coordinator2, in: coordinator1)
        
        XCTAssertEqual(try sut.topCoordinator()?.uuid, coordinator2.uuid)
        await finishFlow(sut: sut)
    }
    
    @MainActor func test_force_to_present_coordinator() async throws {
        let sut = makeSUT()
        let coordinator1 = OtherCoordinator()
        let coordinator2 = AnyCoordinator()
        
        await navigateToCoordinator(coordinator1, in: sut)
        
        try await coordinator2.forcePresentation(
            animated: animated,
            presentationStyle: .fullScreenCover,
            rootCoordinator: sut)
        
        XCTAssertEqual(coordinator2.parent?.uuid, coordinator1.uuid)
        await finishFlow(sut: sut)
    }
    
    @MainActor func test_finishCoordinatorWhichHasChildren() async throws {
        let sut = makeSUT()
        let coordinator1 = OtherCoordinator()
        let coordinator2 = AnyCoordinator()
        let coordinator3 = AnyTabCoordinator()
        
        await navigateToCoordinator(coordinator1, in: sut)
        await navigateToCoordinator(coordinator2, in: coordinator1)
        await navigateToCoordinator(coordinator3, in: coordinator2)
        
        XCTAssertFalse(sut.children.isEmpty)
        await finishFlow(sut: sut)
        
        XCTAssertTrue(sut.children.isEmpty)
        XCTAssertTrue(sut.router.items.isEmpty)
        XCTAssertTrue(sut.router.sheetCoordinator.items.isEmpty)
    }
    
    @MainActor func test_restartCoordinator() async throws {
        let sut = makeSUT()
        
        await sut.router.navigate(toRoute: .pushStep2, animated: animated )
        await sut.router.present(.fullScreenStep)
        await sut.restart()
        
        XCTAssertEqual(sut.children.count, 0)
        XCTAssertEqual(sut.router.items.count, 0)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
    }
    
    // --------------------------------------------------------------------
    // MARK: Helpers
    // --------------------------------------------------------------------
    
    @MainActor private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> AnyCoordinator {
        let coordinator = AnyCoordinator()
        trackForMemoryLeaks(coordinator, file: file, line: line)
        return coordinator
    }
}
