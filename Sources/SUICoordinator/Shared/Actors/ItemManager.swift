//
//  ItemSheetManager.swift
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

/// An actor that manages a collection of items of generic type `T`.
/// It provides thread-safe CRUD (Create, Read, Update, Delete) operations.
actor ItemManager<T> {
    
    private var items: [T] = []
    
    // ---------------------------------------------------------
    // MARK: Create
    // ---------------------------------------------------------
    
    /// Adds an item to the end of the collection.
    /// - Parameter item: The item of type `T` to add.
    func addItem(_ item: T) {
        items.append(item)
    }
    
    /// The index of the last item in the collection (count - 1). Returns 0 if empty.
    var totalItems: Int {
        guard !items.isEmpty else {
            return 0
        }
        return items.count - 1
    }
    
    // ---------------------------------------------------------
    // MARK: Read
    // ---------------------------------------------------------
    
    /// Returns all items in the collection.
    /// - Returns: An array of items of type `T`.
    func getAllItems() -> [T] {
        return items
    }
    
    /// Checks if the collection of items is empty.
    /// - Returns: `true` if the collection is empty, `false` otherwise.
    func areItemsEmpty() -> Bool {
        return items.isEmpty
    }
    
    /// Checks if the given index is a valid index for the collection.
    /// - Parameter index: The index to check.
    /// - Returns: `true` if the index is valid, `false` otherwise.
    func isValid(index: Int) -> Bool {
        items.indices.contains(index)
    }
    
    // ---------------------------------------------------------
    // MARK: Delete
    // ---------------------------------------------------------
    
    /// Removes an item at a specific index.
    /// - Parameter index: The index of the item to remove.
    /// - Returns: The removed item, or `nil` if the index was out of bounds.
    @discardableResult
    func removeItem(at index: Int) -> T? {
        guard isValid(index: index) else { return nil }
        return items.remove(at: index)
    }
    
    /// Removes all items from the collection.
    func removeAllItems() {
        items.removeAll()
    }
        
    /// Removes and returns the last item in the collection.
    /// - Returns: The last item, or `nil` if the collection was empty.
    @discardableResult
    func removeLastItem() -> T? {
        return items.popLast()
    }
    
    func removeAll() {
        guard !areItemsEmpty() else { return }
        return items.removeAll()
    }
    
    func removeItemsIn(range: Range<Int>) {
        items.remove(atOffsets: IndexSet.init(integersIn: range))
    }
}

/// Protocol to identify types that are inherently optional.
/// This is used to provide specialized behavior for `ItemSheetManager` when `T` is an `Optional`.
protocol OptionalType {
    associatedtype Wrapped
    /// Attempts to unwrap the optional value.
    /// - Returns: The wrapped value if non-nil, otherwise `nil`.
    func unwrap() -> Wrapped?
    /// Creates a `nil` instance of this optional type.
    static func from(nilLiteral: ()) -> Self
}

extension Optional: OptionalType {
    func unwrap() -> Wrapped? {
        return self
    }
    static func from(nilLiteral: ()) -> Self {
        return nil
    }
}

/// Extension for `ItemSheetManager` providing specialized methods when its generic type `T` is an `Optional`.
extension ItemManager where T: OptionalType {
    
    /// Retrieves an item at a specific index and attempts to unwrap it.
    /// If `T` is `Optional<Wrapped>`, this returns `Wrapped?`.
    /// - Parameter index: The index of the item to retrieve and unwrap.
    /// - Returns: The unwrapped value if the item at the index is non-nil and contains a value, otherwise `nil`.
    func getItem(at index: Int) -> T.Wrapped? {
        guard items.indices.contains(index) else { return nil }
        return items[index].unwrap()
    }
    
    /// Sets the item at the specified index to its `nil` representation (e.g., `.none`).
    /// This is useful when `T` is an `Optional` type.
    /// - Parameter index: The index of the item to set to `nil`.
    /// - Returns: `true` if the index was valid and the item was set to `nil`, `false` otherwise.
    @discardableResult
    func makeItemNil(at index: Int) -> Bool {
        guard isValid(index: index) else { return false }
        items[index] = T.from(nilLiteral: ())
        return true
    }

    /// Sets the items at the specified indices to their `nil` representation.
    /// - Parameter indexes: An array of indices for items to be set to `nil`.
    func makeItemsNil(at indexes: [Int]) {
        for index in indexes {
            guard isValid(index: index) else { continue }
            items[index] = T.from(nilLiteral: ())
        }
    }
    
    /// Sets the items at the specified variadic indices to their `nil` representation.
    /// - Parameter indexes: A variadic list of indices for items to be set to `nil`.
    func makeItemsNil(at indexes: Int...) {
        makeItemsNil(at: indexes)
    }
    
    /// Sets all items after a specified index to their `nil` representation.
    /// - Parameter index: The index after which all subsequent items will be set to `nil`.
    func makeItemsNil(after index: Int) {
        guard isValid(index: index) else { return }
        for i in (index + 1)..<items.count {
           items[i] = T.from(nilLiteral: ())
        }
    }
    
    /// Sets all items in the collection to their `nil` representation.
    func makeAllItemsNil() {
        items = items.map { _ in T.from(nilLiteral: ()) }
    }

    /// Removes all items from the collection where the wrapped value of the `Optional` `T` is `nil`.
    func removeAllNilItems() {
        items.removeAll(where: { $0.unwrap() == nil })
    }
}
