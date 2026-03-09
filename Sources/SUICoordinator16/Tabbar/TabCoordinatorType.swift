//
//  TabCoordinatorType.swift
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

@MainActor
public protocol TabCoordinatorType: ObservableObject {
    
    associatedtype Page: TabPage
    typealias BadgeItem = (value: String?, page: Page)
    typealias DataSourcePage = Page.DataSource
    
    var currentPage: Page { get set }
    var badges: AsyncStream<(String?, Page)> { get }
    var pages: [Page] { get set }
    var viewContainer: (TabCoordinator<Page>) -> (Page.View) { get }
    
    func getCoordinator(with page: Page) -> AnyCoordinatorType?
    func getCoordinatorSelected() throws -> (any CoordinatorType)
    func clean() async
    func setBadge(for page: Page, with value: String?)
}

/// A type alias representing a coordinator that conforms to both `CoordinatorType` and `TabCoordinatorType`.
public typealias TabCoordinatable = CoordinatorType & TabCoordinatorType
