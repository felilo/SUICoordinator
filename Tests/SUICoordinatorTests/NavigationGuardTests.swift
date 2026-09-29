//
//  NavigationGuardTests.swift
//
//  BOL patch: rapid taps must not stack duplicate screens or orphan child coordinators.
//

import XCTest
@testable import SUICoordinator

final class NavigationGuardTests: XCTestCase {

    // MARK: Router

    @MainActor func test_concurrentPushes_onlyFirstIsAccepted() async {
        let sut = makeRouter()

        async let a: Void = sut.navigate(toRoute: .pushStep2, animated: false)
        async let b: Void = sut.navigate(toRoute: .pushStep3, animated: false)
        async let c: Void = sut.navigate(toRoute: .pushStep(1), animated: false)
        _ = await (a, b, c)

        XCTAssertEqual(sut.items.count, 1)
    }

    @MainActor func test_samePushTwice_isIgnored() async {
        let sut = makeRouter()

        await sut.navigate(toRoute: .pushStep2)
        await sut.navigate(toRoute: .pushStep2)

        XCTAssertEqual(sut.items, [.pushStep2])
    }

    @MainActor func test_sequentialAnimatedPushes_areAllAccepted() async {
        let sut = makeRouter()

        await sut.navigate(toRoute: .pushStep2)
        await sut.navigate(toRoute: .pushStep3)

        XCTAssertEqual(sut.items, [.pushStep2, .pushStep3])
    }

    @MainActor func test_sameSheetTwice_isIgnored() async {
        let sut = makeRouter()

        await sut.navigate(toRoute: .sheetStep, animated: false)
        await sut.navigate(toRoute: .sheetStep, animated: false)

        XCTAssertEqual(sut.sheetCoordinator.items.count, 1)
    }

    // MARK: Child coordinators

    @MainActor func test_concurrentChildCoordinators_onlyFirstIsAccepted() async {
        let sut = AnyCoordinator()

        async let a: Void = sut.navigate(to: AnyCoordinator(), presentationStyle: .push)
        async let b: Void = sut.navigate(to: AnyCoordinator(), presentationStyle: .push)
        async let c: Void = sut.navigate(to: OtherCoordinator(), presentationStyle: .push)
        _ = await (a, b, c)

        XCTAssertEqual(sut.children.count, 1)
        XCTAssertEqual(sut.router.sheetCoordinator.items.count, 1)
    }

    @MainActor func test_lateSameTypeChild_isIgnored_otherTypeIsAccepted() async {
        let sut = AnyCoordinator()

        await sut.navigate(to: AnyCoordinator(), presentationStyle: .push)
        await sut.navigate(to: AnyCoordinator(), presentationStyle: .push)
        XCTAssertEqual(sut.children.count, 1)

        await sut.navigate(to: OtherCoordinator(), presentationStyle: .push)
        XCTAssertEqual(sut.children.count, 2)
    }

    @MainActor func test_everyDismissedChild_isFinished() async throws {
        let sut = AnyCoordinator()
        let first = AnyCoordinator()
        let second = OtherCoordinator()

        await sut.navigate(to: first, presentationStyle: .sheet)
        await sut.navigate(to: second, presentationStyle: .sheet)

        await sut.router.sheetCoordinator.remove(at: "1")
        try await Task.sleep(for: .seconds(0.5))
        XCTAssertEqual(sut.children.map(\.uuid), [first.uuid])

        // Before the patch, removing `second` cleared the only cleanup slot and `first` was orphaned.
        await sut.router.sheetCoordinator.remove(at: "0")
        try await Task.sleep(for: .seconds(0.5))
        XCTAssertTrue(sut.children.isEmpty)
    }

    // MARK: Helpers

    @MainActor private func makeRouter() -> Router<AnyEnumRoute> {
        let router = Router<AnyEnumRoute>()
        router.mainView = .pushStep(1)
        return router
    }
}
