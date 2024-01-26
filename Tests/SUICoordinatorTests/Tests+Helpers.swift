//
//  File.swift
//  
//
//  Created by Andres Lozano on 18/01/24.
//

import XCTest
@testable import SUICoordinator

extension XCTestCase {
    
    typealias Action = () -> Void
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memory leak.", file: file, line: line)
        }
    }
    
    func execute(
        run action: @escaping ( ( Action? ) ) throws -> Void
    ) throws {
        let expectation = XCTestExpectation(description: "Waiting for action")
        try action { expectation.fulfill() }
        wait(for: [expectation], timeout: 1)
    }
    
    func navigateToCoordinator(
        _ nextCoordinator: (any CoordinatorType),
        in coordinator: (any CoordinatorType)
    ) throws {
        try execute {
            coordinator.navigate(
                to: nextCoordinator,
                presentationStyle: .fullScreenCover,
                animated: false,
                completion: $0)
        }
    }
    
    func finishFlow(sut: (any CoordinatorType)) throws {
        try execute { sut.finishFlow(animated: false, completion: $0) }
    }
}
