//
//  TabbarCoordinatorType.swift
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
import Combine

/// A protocol representing a type for managing and coordinating a tabbar-based navigation.
///
/// Tabbar coordinator types define the interface for handling the selected page and badge updates.
public protocol TabbarCoordinatorType {
    
    // ---------------------------------------------------------
    // MARK: Associated Type
    // ---------------------------------------------------------
    
    /// The associated type representing the page associated with the tabbar coordinator.
    associatedtype PAGE
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The current page associated with the tabbar coordinator.
    var currentPage: PAGE { get set }
    
    /// A subject for setting badge values.
    var setBadge: PassthroughSubject<(String?, PAGE), Never> { get set }
    
    // ---------------------------------------------------------
    // MARK: Functions
    // ---------------------------------------------------------
    
    /// Retrieves the selected coordinator within the tabbar coordinator.
    ///
    /// - Returns: The selected coordinator.
    func getCoordinatorSelected() throws -> (any CoordinatorType)
}

/// A type alias representing a coordinator that conforms to both `CoordinatorType` and `TabbarCoordinatorType`.
public typealias TabbarCoordinatable = CoordinatorType & TabbarCoordinatorType
