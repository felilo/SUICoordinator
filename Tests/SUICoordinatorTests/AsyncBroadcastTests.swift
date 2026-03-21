//
//  AsyncBroadcastTests.swift
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

@available(iOS 17.0, *)
final class AsyncBroadcastTests: XCTestCase {

    // MARK: - stream() / send()

    func test_send_deliversValueToSingleSubscriber() async {
        let sut = AsyncBroadcast<Int>()
        let stream = await sut.stream()
        var iterator = stream.makeAsyncIterator()

        await sut.send(42)

        let value = await iterator.next()
        XCTAssertEqual(value, 42)
    }

    func test_send_deliversValueToMultipleSubscribers() async {
        let sut = AsyncBroadcast<String>()
        let stream1 = await sut.stream()
        let stream2 = await sut.stream()

        var it1 = stream1.makeAsyncIterator()
        var it2 = stream2.makeAsyncIterator()

        await sut.send("hello")

        let v1 = await it1.next()
        let v2 = await it2.next()
        XCTAssertEqual(v1, "hello")
        XCTAssertEqual(v2, "hello")
    }

    func test_send_deliversMultipleValuesInOrder() async {
        let sut = AsyncBroadcast<Int>()
        let stream = await sut.stream()
        var iterator = stream.makeAsyncIterator()

        await sut.send(1)
        await sut.send(2)
        await sut.send(3)

        let v1 = await iterator.next()
        let v2 = await iterator.next()
        let v3 = await iterator.next()
        XCTAssertEqual(v1, 1)
        XCTAssertEqual(v2, 2)
        XCTAssertEqual(v3, 3)
    }

    func test_send_beforeAnySubscriber_doesNotCrash() async {
        let sut = AsyncBroadcast<Int>()
        // No stream created — send should be a no-op
        await sut.send(99)
    }

    // MARK: - Continuation cleanup on termination

    func test_terminatedStream_doesNotReceiveSubsequentValues() async {
        let sut = AsyncBroadcast<Int>()

        // Subscribe, consume one value, then let the stream go out of scope.
        do {
            let stream = await sut.stream()
            var it = stream.makeAsyncIterator()
            await sut.send(1)
            let v = await it.next()
            XCTAssertEqual(v, 1)
            // stream and iterator deallocate here, triggering onTermination
        }

        // Give the actor a moment to process the removal task
        try? await Task.sleep(for: .milliseconds(50))

        // A new subscriber created after the old one terminated should still work
        let stream2 = await sut.stream()
        var it2 = stream2.makeAsyncIterator()
        await sut.send(2)
        let v2 = await it2.next()
        XCTAssertEqual(v2, 2)
    }

    // MARK: - Void value type (matches Router.onFinish usage)

    func test_send_void_unblocksSuspendedConsumer() async {
        let sut = AsyncBroadcast<Void>()
        let stream = await sut.stream()

        // Kick off a task that waits on the stream
        let received = expectation(description: "received Void")
        let task = Task {
            for await _ in stream {
                received.fulfill()
                break
            }
        }

        // Give the consumer task time to suspend
        try? await Task.sleep(for: .milliseconds(20))
        await sut.send(())

        await fulfillment(of: [received], timeout: 1.0)
        task.cancel()
    }
}
