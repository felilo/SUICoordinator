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
import Combine
@testable import SUICoordinator

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memory leak.", file: file, line: line)
        }
    }
    
    func navigateToCoordinator(
        _ nextCoordinator: (any CoordinatorType),
        in coordinator: (any CoordinatorType)
    ) async {
        await coordinator.navigate(
            to: nextCoordinator,
            presentationStyle: .fullScreenCover,
            animated: false)
        await nextCoordinator.start(animated: false)
    }
    
    func finishFlow(sut: (any CoordinatorType)) async {
        await sut.finishFlow(animated: false)
    }
    
    /*
     - Parameters:
     - publisher: The publisher to execute.
     - action: The action to perform upon completion.
     */
    func execute<T>(
        _ publisher: AnyPublisher<T, Error>,
        _ action: (( Result<T, Error> ) -> Void)? = nil
    ) {
        
        let expectation = XCTestExpectation(description: "Waiting for action")
        var cancellables = Set<AnyCancellable>()
        
        publisher
            .sink(
                receiveCompletion: { result in
                    guard case .failure(let error) = result else {
                        return expectation.fulfill()
                    }
                    action?(.failure(error))
                    expectation.fulfill()
                },
                receiveValue: { value in
                    action?(.success(value))
                }
            ).store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
    }
    
    /**
        
     */
    func getNameOf<T>(object: T) -> String {
        String(describing: object.self).replacingOccurrences(of: "()", with: "")
    }
}
