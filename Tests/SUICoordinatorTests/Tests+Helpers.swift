//
//  Tests+Helpers.swift
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
