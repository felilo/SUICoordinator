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

@available(iOS 17.0, *)
@MainActor
final class CoordinatorTests: XCTestCase {
    
    private let animated: Bool = false
    
    func test_finishFlow() async throws {
        let sut = makeSUT()
        
        await sut.router.navigate(toRoute: .pushStep2, animated: animated )
        await sut.router.navigate(toRoute: .sheetStep, animated: animated )
        
        await finishFlow(sut: sut)
        XCTAssertEqual(sut.router.items.count, 0)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
    }
    
    func test_CleanCoordinator() async throws {
        let sut = makeSUT()
        
        await sut.router.navigate(toRoute: .pushStep2, animated: animated )
        await sut.router.navigate(toRoute: .sheetStep, animated: animated )
        
        await finishFlow(sut: sut)
        XCTAssertEqual(sut.router.items.count, 0)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
    }
    
    func test_finishFlow_swipedAway() async throws {
        let sut = makeSUT()
        let anyCoordinator = AnyCoordinator()
        
        await sut.navigate(to: anyCoordinator, presentationStyle: .sheet)
        await sut.router.sheetCoordinator.remove(at: "\(0)")
        
        try await Task.sleep(for: .seconds(0.5))
        
        XCTAssertEqual(anyCoordinator.router.items.count, 0)
        XCTAssertEqual(anyCoordinator.router.sheetCoordinator.items.count, 0)
    }
    
    func test_finishFlow_mainCoordinator() async throws {
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
    
    func test_finishFlow_childCoordinator() async throws {
        let coordinator = OtherCoordinator()
        let sut = makeSUT()
        
        await sut.start()
        await navigateToCoordinator(sut, in: coordinator)
        
        await finishFlow(sut: sut)
        XCTAssertEqual(sut.router.items.count, 0)
        XCTAssertTrue(sut.children.isEmpty)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
    }
    
    func test_starFlow() async throws {
        let sut = makeSUT()
        let route = AnyEnumRoute.fullScreenStep

        await sut.startFlow(route: route)
        let mainView = try XCTUnwrap(sut.router.mainView)
        
        XCTAssertEqual(mainView, route)
        XCTAssertTrue(sut.isRunning)
    }
    
    func test_parentCoordinator_not_nil() async throws {
        let sut = makeSUT()
        let coordinator = OtherCoordinator()
        
        await navigateToCoordinator(coordinator, in: sut)
        
        XCTAssertEqual(coordinator.parent?.uuid, sut.uuid)
        await finishFlow(sut: sut)
    }
    
    func test_navigateToCoordinator() async throws {
        let sut = makeSUT()
        let coordinator = OtherCoordinator()
        
        await navigateToCoordinator(coordinator, in: sut)
        
        XCTAssertEqual(sut.children.last?.id, coordinator.id)
        XCTAssertEqual(sut.uuid, coordinator.parent?.uuid)
        await finishFlow(sut: sut)
    }
    
    func test_navigateToCoordinator_with_customTransition() async throws {
        let sut = makeSUT()
        let coordinator = OtherCoordinator()
        
        await navigateToCoordinator(coordinator, in: sut, presentationStyle: .push)
        
        XCTAssertEqual(sut.children.last?.id, coordinator.id)
        XCTAssertEqual(sut.uuid, coordinator.parent?.uuid)
        await finishFlow(sut: sut)
    }
    
    func test_getTopmostCoordinator() async throws {
        let sut = makeSUT()
        let coordinator1 = OtherCoordinator()
        let coordinator2 = AnyCoordinator()
        
        await navigateToCoordinator(coordinator1, in: sut)
        await navigateToCoordinator(coordinator2, in: coordinator1)
        
        XCTAssertEqual(try sut.topCoordinator()?.uuid, coordinator2.uuid)
        await finishFlow(sut: sut)
    }
    
    func test_force_to_present_coordinator() async throws {
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
    
    func test_finishCoordinatorWhichHasChildren() async throws {
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
    
    func test_restartCoordinator() async throws {
        let sut = makeSUT()
        
        await sut.router.navigate(toRoute: .pushStep2, animated: animated )
        await sut.router.present(.fullScreenStep)
        await sut.restart()
        
        XCTAssertEqual(sut.children.count, 0)
        XCTAssertEqual(sut.router.items.count, 0)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
    }
    
    // MARK: - isRunning

    func test_isRunning_falseBeforeStart() async {
        let sut = makeSUT()
        XCTAssertFalse(sut.isRunning)
    }

    func test_isRunning_trueAfterStartFlow() async {
        let sut = makeSUT()
        await sut.startFlow(route: .pushStep(1))
        XCTAssertTrue(sut.isRunning)
    }

    // MARK: - isTabCoordinable

    func test_isTabCoordinable_falseForRegularCoordinator() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isTabCoordinable)
    }

    func test_isTabCoordinable_trueForTabCoordinator() {
        let tab = AnyTabCoordinator()
        XCTAssertTrue(tab.isTabCoordinable)
    }

    // MARK: - isEmptyCoordinator

    func test_isEmptyCoordinator_trueWhenNoMainView() {
        let sut = makeSUT()
        XCTAssertTrue(sut.isEmptyCoordinator)
    }

    func test_isEmptyCoordinator_falseAfterStartFlow() async {
        let sut = makeSUT()
        await sut.startFlow(route: .pushStep(1))
        XCTAssertFalse(sut.isEmptyCoordinator)
    }

    // MARK: - removeChildren

    func test_removeChildren_clearsAllChildren() async {
        let sut = makeSUT()
        let child1 = OtherCoordinator()
        let child2 = AnyCoordinator()

        await navigateToCoordinator(child1, in: sut)
        await navigateToCoordinator(child2, in: sut)
        XCTAssertEqual(sut.children.count, 2)

        await sut.removeChildren(animated: animated)
        XCTAssertTrue(sut.children.isEmpty)
    }

    // MARK: - close

    func test_close_popsLastPushedRoute() async {
        let sut = makeSUT()
        await sut.startFlow(route: .pushStep(1))
        await sut.router.navigate(toRoute: .pushStep2, animated: animated)
        XCTAssertEqual(sut.router.items.count, 1)

        await sut.close(animated: animated)
        XCTAssertEqual(sut.router.items.count, 0)
    }

    func test_close_dismissesLastSheet() async {
        let sut = makeSUT()
        await sut.startFlow(route: .pushStep(1))
        await sut.router.navigate(toRoute: .sheetStep, animated: animated)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 1)

        await sut.close(animated: animated)
        await sut.router.sheetCoordinator.removeAllNilItems()
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 0)
    }

    // MARK: - getCoordinatorPresented

    func test_getCoordinatorPresented_returnsSelf_whenNoChildren() async throws {
        let sut = makeSUT()
        await sut.startFlow(route: .pushStep(1))
        let presented = try sut.getCoordinatorPresented()
        XCTAssertEqual(presented?.uuid, sut.uuid)
    }

    func test_getCoordinatorPresented_returnsDeepestChild() async throws {
        let sut = makeSUT()
        let child1 = OtherCoordinator()
        let child2 = AnyCoordinator()

        await sut.start()
        await navigateToCoordinator(child1, in: sut)
        await navigateToCoordinator(child2, in: child1)

        let presented = try sut.getCoordinatorPresented()
        XCTAssertEqual(presented?.uuid, child2.uuid)
        await finishFlow(sut: sut)
    }

    // MARK: - navigate(toRoute:) presentation styles

    func test_navigateToRoute_sheet_addsToSheetCoordinator() async {
        let sut = makeSUT()
        await sut.startFlow(route: .pushStep(1))
        await sut.navigate(toRoute: .sheetStep, animated: animated)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 1)
        await finishFlow(sut: sut)
    }

    func test_navigateToRoute_push_addsToItems() async {
        let sut = makeSUT()
        await sut.startFlow(route: .pushStep(1))
        await sut.navigate(toRoute: .pushStep2, animated: animated)
        XCTAssertEqual(sut.router.items.count, 1)
        await finishFlow(sut: sut)
    }

    func test_navigateToRoute_detents_addsToSheetCoordinator() async {
        let sut = makeSUT()
        await sut.startFlow(route: .pushStep(1))
        await sut.navigate(toRoute: .detentsStep, animated: animated)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 1)
        await finishFlow(sut: sut)
    }

    // MARK: - children / parent relationship

    func test_removeChild_removesSpecificChild() async {
        let sut = makeSUT()
        let child1 = OtherCoordinator()
        let child2 = AnyCoordinator()

        await navigateToCoordinator(child1, in: sut)
        await navigateToCoordinator(child2, in: sut)
        XCTAssertEqual(sut.children.count, 2)

        await sut.removeChild(coordinator: child1)
        XCTAssertEqual(sut.children.count, 1)
        XCTAssertEqual(sut.children.first?.uuid, child2.uuid)
        await finishFlow(sut: sut)
    }

    // --------------------------------------------------------------------
    // MARK: Helpers
    // --------------------------------------------------------------------

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> AnyCoordinator {
        let coordinator = AnyCoordinator()
        trackForMemoryLeaks(coordinator, file: file, line: line)
        return coordinator
    }
}
