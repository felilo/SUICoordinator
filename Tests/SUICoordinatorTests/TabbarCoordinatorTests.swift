//
//  TabbarCoordinatorTests.swift
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


final class TabbarCoordinatorTests: XCTestCase {
    
    func test_setPages() async throws {
        let sut = makeSUT()
        let pages = [AnyEnumTabbarRoute.tab2]
        
        await sut.start(animated: false)
        await sut.setPages(pages)
        
        XCTAssertEqual(pages, sut.pages)
        await finishFlow(sut: sut)
    }
    
    func test_changeTab() async throws {
        let sut = makeSUT(currentPage: .tab1)
        
        XCTAssertEqual(sut.currentPage, .tab1)
        sut.currentPage = .tab2
        XCTAssertEqual(sut.currentPage, .tab2)
        await finishFlow(sut: sut)
    }
    
    func test_get_coordinator_selected_fail() async {
        let sut = makeSUT(currentPage: .tab1)
        
        XCTAssertEqual(sut.currentPage, .tab1)
        sut.currentPage = .tab2
        XCTAssertEqual(sut.currentPage, .tab2)
        await sut.setPages([])
        
        XCTAssertThrowsError(try sut.getCoordinatorSelected(), "Expected error xxx got success") { error in
            XCTAssertEqual(error.localizedDescription, TabbarCoordinatorError.coordinatorSelected.localizedDescription)
        }
        await finishFlow(sut: sut)
    }
    
    func test_navigateToCoordinator() async throws {
        let sut = makeSUT(currentPage: .tab1)
        let coordinator = AnyCoordinator()
        
        await sut.start(animated: false)
        XCTAssertEqual(sut.currentPage, .tab1)
        sut.currentPage = .tab2
        await navigateToCoordinator(coordinator, in: try sut.getCoordinatorSelected())
        XCTAssertEqual(coordinator.parent.uuid, try sut.getCoordinatorSelected().uuid)
        await finishFlow(sut: sut)
    }
    
    func test_finshCoordinator() async throws {
        let sut = makeSUT()
        let coordinator1 = OtherCoordinator()
        let coordinator2 = AnyCoordinator()
        
        await navigateToCoordinator(coordinator1, in: sut)
        await navigateToCoordinator(coordinator2, in: coordinator1)
        await finishFlow(sut: sut)
        
        XCTAssertTrue(sut.children.isEmpty)
        XCTAssertTrue(sut.router.items.isEmpty)
        XCTAssertTrue(sut.router.sheetCoordinator.items.isEmpty)
        XCTAssertNil(sut.router.mainView)
    }
    
    func test_force_to_present_coordinator() async throws {
        let sut = makeSUT(currentPage: .tab1)
        let coordinator = AnyCoordinator()
        
        await sut.start(animated: false)
        XCTAssertEqual(sut.currentPage, .tab1)
        sut.currentPage = .tab2
        try await coordinator.forcePresentation(
            animated: false,
            presentationStyle: .fullScreenCover,
            mainCoordinator: sut)
        await coordinator.start(animated: false)
        
        XCTAssertEqual(coordinator.parent.uuid, try sut.getCoordinatorSelected().uuid)
        await finishFlow(sut: sut)
    }
    
    
    // --------------------------------------------------------------------
    // MARK: Helpers
    // --------------------------------------------------------------------
    
    private func makeSUT(
        currentPage: AnyEnumTabbarRoute = AnyEnumTabbarRoute.tab1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> AnyTabbarCoordinator {
        let parent = OtherCoordinator()
        let coordinator = AnyTabbarCoordinator(currentPage: currentPage)
        
        coordinator.parent = parent
        parent.children.append(coordinator)
        
        trackForMemoryLeaks(coordinator, file: file, line: line)
        return coordinator
    }
}
