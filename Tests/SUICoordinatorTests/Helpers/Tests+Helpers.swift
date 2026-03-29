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
@preconcurrency import Combine
@testable import SUICoordinator

extension XCTestCase {
    
    @MainActor func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { @MainActor [weak instance] in
            XCTAssertNil(instance, "Potential memory leak.", file: file, line: line)
        }
    }
    
    @available(iOS 17.0, *)
    @MainActor func navigateToCoordinator(
        _ nextCoordinator: (any CoordinatorType),
        in coordinator: (any CoordinatorType),
        presentationStyle: TransitionPresentationStyle = .fullScreenCover,
        animated: Bool = false
    ) async {
        await coordinator.navigate(
            to: nextCoordinator,
            presentationStyle: presentationStyle,
            animated: animated)
        
        await nextCoordinator.start()
    }
    
    @available(iOS 17.0, *)
    @MainActor func finishFlow(sut: (any CoordinatorType), animated: Bool = false) async {
        await sut.finishFlow(animated: animated)
    }
    
    /// Fires a `SheetCoordinator`'s `onFinish` signal at `index` once `removeSheet`
    /// starts listening, then awaits the given operation. Used in unit tests to
    /// unblock `removeSheet` calls that wait for the view-layer dismissal confirmation.
    @available(iOS 17.0, *)
    @MainActor func simulateSheetDismissal<T>(
        _ sheetCoordinator: SheetCoordinator<T>,
        at index: Int = 0,
        performing operation: @escaping () async -> Void
    ) async {
        
        await simulateDismissal([DismissalStringItem(broadcast: sheetCoordinator.onFinish, events: [{
            await sheetCoordinator.onFinish.send("\(index)")
        }])], performing: operation)
    }
    
    @available(iOS 17.0, *)
    @MainActor func simulateDismissal(
        _ items: [any DismissalItemProtocol],
        performing operation: @escaping () async -> Void
    ) async {
        
        await withTaskGroup(of: Void.self) { group in
            // Run main operation
            group.addTask { await operation() }
            
            // Handle each item concurrently
            for item in items {
                group.addTask {
                    while await item.getSubscriberCount() == 0 { await Task.yield() }
                    for event in item.events { await event() }
                }
            }
        }
    }

    func asyncStream<T: Sendable, E: Error>(_ stream: any Publisher<T, E>) -> AsyncStream<T> {
        AsyncStream { continuation in
            
            let cancellable = stream.sink { completion in
                continuation.finish()
            } receiveValue: { value in
                continuation.yield(value)
            }
            
            continuation.onTermination = { continuation in
                cancellable.cancel()
            }
        }
    }
}

struct DismissalVoidItem: DismissalItemProtocol {
    let broadcast: AsyncBroadcast<Void>
    let events: [() async -> Void]
}

struct DismissalStringItem: DismissalItemProtocol {
    let broadcast: AsyncBroadcast<String>
    let events: [() async -> Void]
}

protocol DismissalItemProtocol {
    associatedtype E: Sendable
    
    var broadcast: AsyncBroadcast<E> { get }
    var events: [() async -> Void] { get }
}

extension DismissalItemProtocol {
    func getSubscriberCount() async ->  Int {
        await broadcast.subscriberCount
    }
}
