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
public protocol TabbarCoordinatorType: ObservableObject {
    
    // ---------------------------------------------------------
    // MARK: Associated Type
    // ---------------------------------------------------------
    
    /// The associated type representing the page associated with the tabbar coordinator.
    ///
    /// This must conform to the `TabbarPage` protocol to ensure the page has the necessary properties and behavior.
    associatedtype Page: TabbarPage
    
    /// A typealias representing a badge item.
    ///
    /// A badge item includes an optional `value` (e.g., a string representing a notification count)
    /// and a `page` to which the badge is associated.
    typealias BadgeItem = (value: String?, page: Page)
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The currently selected page in the tabbar coordinator.
    ///
    /// This property keeps track of the active page in the tab bar interface.
    var currentPage: Page { get set }
    
    /// A subject used for setting badge values on specific pages.
    ///
    /// This property allows you to asynchronously assign badges to pages using a tuple containing
    /// the badge value and the associated page.
    var setBadge: PassthroughSubject<(String?, Page), Never> { get set }
    
    /// An array representing all the pages managed by the tabbar coordinator.
    ///
    /// This property contains the complete list of pages, which typically corresponds to the tabs
    /// displayed in the tab bar.
    var pages: [Page] { get set }
    
    /// A custom view associated with the tabbar coordinator.
    ///
    /// This closure provides a SwiftUI view for customization, which can be associated with a specific
    /// `Page`. The view is optional and can be left `nil` if no custom view is needed.
    var customView: (() -> (Page.View))? { get set }
    
    // ---------------------------------------------------------
    // MARK: Functions
    // ---------------------------------------------------------
    
    /// Retrieves the coordinator at a specified position in the tabbar.
    ///
    /// - Parameter position: The index of the coordinator to retrieve.
    /// - Returns: The coordinator at the specified position, or `nil` if no coordinator exists at that index.
    func getCoordinator(with position: Int) -> (any CoordinatorType)?
    
    /// Retrieves the currently selected coordinator within the tabbar.
    ///
    /// - Returns: The coordinator that corresponds to the selected tab.
    /// - Throws: An error if the selected coordinator cannot be determined.
    func getCoordinatorSelected() throws -> (any CoordinatorType)
}

/// A type alias representing a coordinator that conforms to both `CoordinatorType` and `TabbarCoordinatorType`.
public typealias TabbarCoordinatable = CoordinatorType & TabbarCoordinatorType
