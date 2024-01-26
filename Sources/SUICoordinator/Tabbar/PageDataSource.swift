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

/**
 A protocol defining the requirements for a page data source.

 The `PageDataSource` protocol includes properties and methods necessary for providing information about a page in a tab bar or similar interface.

 - Important: The `title` property represents the title view associated with the page.

 - Note: The `icon` property represents the icon view associated with the page.

 - Warning: The `position` property specifies the position of the page in the interface.  It must start from 0 and the numbers be consecutive

 Example usage:
 ```swift
 // Conform to the PageDataSource protocol and implement the required properties.
 struct MyPageDataSource: PageDataSource {
	 var title: some View {
		 // Implementation of the title view
	 }

	 var icon: some View {
		 // Implementation of the icon view
	 }

	 var position: Int {
		 // Implementation of the position property
	 }
 }
 */
public protocol PageDataSource: SCHashable {
	
	
	typealias View = (any SwiftUI.View)
	
	// ---------------------------------------------------------
	// MARK: Properties
	// ---------------------------------------------------------
	
	/// The title view associated with the page.
	@ViewBuilder
	var title: View  { get }
	
	/// The icon view associated with the page.
	@ViewBuilder
	var icon: View { get }
	
	/// The position of the page in the interface.
	var position: Int { get }
}


public extension PageDataSource where Self: CaseIterable {
	
	static func sortedByPosition() -> [Self] {
		Self.allCases.sorted(by: { $0.position < $1.position })
	}
}

public typealias TabbarPage = PageDataSource & TabbarNavigationRouter
