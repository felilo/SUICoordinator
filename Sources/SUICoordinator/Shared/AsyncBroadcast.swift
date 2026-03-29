//
//  AsyncBroadcast.swift
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

import Foundation

/// A lightweight actor-based broadcast channel that fans a single sent value out
/// to all active `AsyncStream` subscribers.
///
/// Each call to `stream()` registers a new subscriber and returns a dedicated
/// `AsyncStream`. When `send(_:)` is called, every registered stream receives the
/// value. Subscribers are automatically deregistered when their stream terminates
/// (e.g. the `for await` loop is cancelled or the consuming task ends).
///
/// `AsyncBroadcast` is an actor, so all mutations to the subscriber table are
/// serialised without external locking.
actor AsyncBroadcast<Value: Sendable> {

    /// Active subscriber continuations, keyed by a unique identifier assigned at
    /// subscription time.
    private var continuations: [UUID: AsyncStream<Value>.Continuation] = [:]

    /// Creates a new `AsyncStream` and registers it as a subscriber.
    ///
    /// The stream stays active until the caller's `for await` loop exits or the
    /// enclosing task is cancelled, at which point the continuation's `onTermination`
    /// handler removes it from the active set.
    ///
    /// - Returns: An `AsyncStream` that yields every value passed to `send(_:)`.
    func stream() -> AsyncStream<Value> {
        let id = UUID()

        return AsyncStream { continuation in
            continuations[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeContinuation(id) }
            }
        }
    }

    /// The number of currently active subscribers.
    var subscriberCount: Int {
        continuations.count
    }

    /// Broadcasts `value` to all active subscribers.
    ///
    /// - Parameter value: The value to deliver to every registered stream.
    func send(_ value: Value) {
        for continuation in continuations.values {
            continuation.yield(value)
        }
    }

    /// Removes the continuation identified by `id` from the active subscriber table.
    ///
    /// Called automatically via the stream's `onTermination` handler when a subscriber
    /// cancels or finishes iterating.
    ///
    /// - Parameter id: The identifier of the continuation to remove.
    private func removeContinuation(_ id: UUID) {
        continuations.removeValue(forKey: id)
    }
}
