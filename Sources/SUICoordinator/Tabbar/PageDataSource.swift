//
//  PageDataSource.swift
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

import SwiftUI

/// A protocol representing a data source for a page in a tabbar-based navigation.
///
/// Page data sources provide information such as title, icon, and position for a tabbar page.
public protocol PageDataSource: SCHashable {
    
    /// A type alias representing a SwiftUI view.
    typealias View = (any SwiftUI.View)
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The title view for the page.
    @ViewBuilder
    var title: View  { get }
    
    /// The icon view for the page.
    @ViewBuilder
    var icon: View { get }
    
    /// The position of the page in the tabbar.
    var position: Int { get }
}

/// An extension for `PageDataSource` to provide a method for sorting data sources by position.
public extension PageDataSource where Self: CaseIterable {
    
    /// Sorts all cases of `PageDataSource` by their position.
    ///
    /// - Returns: An array of sorted `PageDataSource` cases.
    static func sortedByPosition() -> [Self] {
        Self.allCases.sorted(by: { $0.position < $1.position })
    }
}

/// A type alias representing a page in a tabbar navigation with both `PageDataSource` and `TabbarNavigationRouter` conformances.
public typealias TabPage = PageDataSource & TabNavigationRouter & SCEquatable

