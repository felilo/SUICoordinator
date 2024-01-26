//
//  TabbarPageDataSource.swift
//  CRNavigation
//
//  Created by Andres Lozano on 11/12/23.
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
