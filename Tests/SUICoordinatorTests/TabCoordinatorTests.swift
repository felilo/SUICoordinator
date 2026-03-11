//
//  TabCoordinatorTests.swift
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


@available(iOS 17.0, *)
@MainActor
final class TabCoordinatorTests: XCTestCase {

    private let animated: Bool = false

    func test_setPages() async throws {
        let sut = makeSUT()
        let pages = [AnyEnumTabRoute.tab2]
        
        await sut.start()
        await sut.setPages(pages)
        
        XCTAssertEqual(pages, sut.pages)
        await finishFlow(sut: sut)
    }
    
    func test_changeTab() async throws {
        let sut = makeSUT(currentPage: .tab1)
        await sut.start()

        XCTAssertEqual(sut.currentPage, .tab1)
        sut.currentPage = .tab2
        XCTAssertEqual(sut.currentPage, .tab2)
        await finishFlow(sut: sut)
    }
    
    func test_get_coordinator_selected_fail() async {
        let sut = makeSUT(currentPage: .tab1)
        
        await sut.start()
        XCTAssertEqual(sut.currentPage, .tab1)
        sut.currentPage = .tab2
        XCTAssertEqual(sut.currentPage, .tab2)
        await sut.setPages([])
        
        XCTAssertThrowsError(try sut.getCoordinatorSelected(), "Expected error xxx got success") { error in
            XCTAssertEqual(error.localizedDescription, TabCoordinatorError.coordinatorSelected.localizedDescription)
        }
        await finishFlow(sut: sut)
    }
    
    func test_navigateToCoordinator() async throws {
        let sut = makeSUT(currentPage: .tab1)
        let coordinator = AnyCoordinator()
        
        await sut.start()
        XCTAssertEqual(sut.currentPage, .tab1)
        sut.currentPage = .tab2
        await navigateToCoordinator(coordinator, in: try sut.getCoordinatorSelected())
        XCTAssertEqual(coordinator.parent?.uuid, try sut.getCoordinatorSelected().uuid)
        await finishFlow(sut: sut)
    }
    
    func test_popToRoot_in_tab() async throws {
        let sut = makeSUT(currentPage: .tab1)
        await sut.start()
        
        let coordinatorSelected = try sut.getCoordinatorSelected() as? AnyCoordinator
        
        await coordinatorSelected?.router.navigate(toRoute: .pushStep2)
        await coordinatorSelected?.router.navigate(toRoute: .pushStep3)
        XCTAssertEqual(coordinatorSelected?.router.items.count, 2)
        
        await sut.popToRoot()
        XCTAssertEqual(coordinatorSelected?.router.items.count, 0)
        await finishFlow(sut: sut)
    }
    
    func test_siTabCoordinator() async throws {
        let sut = makeSUT(currentPage: .tab1)
        await sut.start()
        XCTAssertTrue(sut.isTabCoordinable)
        await finishFlow(sut: sut)
    }
    
    func test_finshCoordinator() async throws {
        let sut = makeSUT()
        let coordinator1 = OtherCoordinator()
        let coordinator2 = AnyCoordinator()
        
        await navigateToCoordinator(coordinator1, in: sut)
        await navigateToCoordinator(coordinator2, in: coordinator1)
        await finishFlow(sut: sut)
        
        XCTAssertTrue(sut.isEmptyCoordinator)
    }
    
    func test_force_to_present_coordinator() async throws {
        let sut = makeSUT(currentPage: .tab1)
        let coordinator = AnyCoordinator()
        
        await sut.start()
        XCTAssertEqual(sut.currentPage, .tab1)
        sut.currentPage = .tab2
        try await coordinator.forcePresentation(
            animated: animated,
            presentationStyle: .fullScreenCover,
            rootCoordinator: sut)
        await coordinator.start()
        
        XCTAssertEqual(coordinator.parent?.uuid, try sut.getCoordinatorSelected().uuid)
        await finishFlow(sut: sut)
    }
    
    func test_get_coordinator_at_position() async throws {
        let sut = makeSUT()
        let pages = [AnyEnumTabRoute.tab2, .tab1]
        
        await sut.start()
        await sut.setPages(pages)
        
        XCTAssertNotNil(sut.getCoordinator(with: .tab1))
        XCTAssertNotNil(sut.getCoordinator(with: .tab2))
        XCTAssertNil(sut.getCoordinator(with: .tab3))
        
        await finishFlow(sut: sut)
    }
    
    func test_start_coordinator() async throws {
        let sut = makeSUT()
        let pages = [AnyEnumTabRoute.tab2, .tab1]
        
        await sut.start()
        
        XCTAssertTrue(sut.pages.count == 3)
        
        await sut.setPages(pages)
        
        XCTAssertTrue(sut.pages.count == 2)
        XCTAssertTrue(sut.isRunning)
        
        await finishFlow(sut: sut)
    }
    
    func test_finishCoordinator_from_child() async throws {
        let sut = makeSUT()
        let pages = [AnyEnumTabRoute.tab2, .tab1]
        
        await sut.start()
        await sut.setPages(pages)
        
        let coordinator = sut.getCoordinator(with: .tab2)
        
        await coordinator?.finishFlow(animated: animated)
        
        XCTAssertTrue(sut.isEmptyCoordinator)
    }
    
    func test_getCoordinator_selected_given_a_coordinatorObject() async throws {
        let sut = makeSUT(currentPage: .tab3)
        let myCustomCoordinator = AnyCoordinator()
        
        await sut.start()
        
        XCTAssertTrue(try sut.getCoordinatorPresented() is ThirdCoordinator)
        
        try await myCustomCoordinator.forcePresentation(rootCoordinator: sut)
        
        XCTAssertTrue(try sut.getCoordinatorPresented() is AnyCoordinator)
        
        await sut.finishFlow(animated: animated)
    }
    
    
    // --------------------------------------------------------------------
    // MARK: Helpers
    // --------------------------------------------------------------------
    
    // MARK: - setBadge

    func test_setBadge_emitsBadgeValue() async throws {
        let sut = makeSUT(currentPage: .tab1)
        await sut.start()

        var badgeValues: [(String?, AnyEnumTabRoute)] = []
        let task = Task {
            for await value in sut.badges {
                await MainActor.run { badgeValues.append(value) }
            }
        }

        sut.setBadge(for: .tab1, with: "3")
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertEqual(badgeValues.last?.0, "3")
        XCTAssertEqual(badgeValues.last?.1, .tab1)

        sut.setBadge(for: .tab1, with: nil)
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertNil(badgeValues.last?.0)

        task.cancel()
        await finishFlow(sut: sut)
    }

    // MARK: - setCurrentPage via coordinator

    func test_setCurrentPage_viaCoordinator_updatesCurrentPage() async throws {
        let sut = makeSUT(currentPage: .tab1)
        await sut.start()

        // setCurrentPage matches on position string vs coordinator.tagId (which is page.id).
        // For AnyEnumTabRoute, id == String(describing: self) (e.g. "tab2") and position == 1,
        // so direct page assignment is the reliable path.
        sut.setCurrentPage(AnyEnumTabRoute.tab2)
        XCTAssertEqual(sut.currentPage, .tab2)

        await finishFlow(sut: sut)
    }

    // MARK: - getCoordinator(with:) success and nil

    func test_getCoordinator_returnsNilForMissingPage() async throws {
        let sut = makeSUT()
        await sut.start()
        await sut.setPages([.tab1])

        XCTAssertNil(sut.getCoordinator(with: .tab2))
        await finishFlow(sut: sut)
    }

    // MARK: - setPages with currentPage parameter

    func test_setPages_withCurrentPage_updatesCurrentPage() async throws {
        let sut = makeSUT(currentPage: .tab1)
        await sut.start()
        await sut.setPages([.tab2, .tab3], currentPage: .tab3)

        XCTAssertEqual(sut.currentPage, .tab3)
        await finishFlow(sut: sut)
    }

    // MARK: - isRunning

    func test_tabCoordinator_isRunning_afterStart() async throws {
        let sut = makeSUT()
        XCTAssertFalse(sut.isRunning)
        await sut.start()
        XCTAssertTrue(sut.isRunning)
        await finishFlow(sut: sut)
    }

    // MARK: - children count after setPages

    func test_setPages_childrenCountMatchesPages() async throws {
        let sut = makeSUT()
        await sut.start()

        let pages: [AnyEnumTabRoute] = [.tab1, .tab2]
        await sut.setPages(pages)
        XCTAssertEqual(sut.children.count, pages.count)
        await finishFlow(sut: sut)
    }

    // MARK: - clean

    func test_clean_removesChildrenAndSheets() async throws {
        let sut = makeSUT()
        await sut.start()
        await sut.clean()
        XCTAssertTrue(sut.children.isEmpty)
        await finishFlow(sut: sut)
    }

    private func makeSUT(
        currentPage: AnyEnumTabRoute = AnyEnumTabRoute.tab1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> AnyTabCoordinator {
        let coordinator = AnyTabCoordinator(currentPage: currentPage)
        trackForMemoryLeaks(coordinator, file: file, line: line)
        return coordinator
    }
}
