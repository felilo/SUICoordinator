//
//  TabbarCoordinator.swift
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

/**
 A coordinator responsible for managing a tab bar interface with multiple pages.

 The `TabbarCoordinator` class conforms to the `Coordinator` protocol and the `TabbarCoordinatorType` protocol, providing functionality for handling a tab bar interface with multiple pages. It supports the selection of different pages and provides customization options for presentation styles.
 - Important: This coordinator provides a flexible and customizable solution for managing a tab bar interface in a coordinated app architecture.
 */
open class TabbarCoordinator<Page>: Coordinator<RouteBase>, TabbarCoordinatorType where Page: TabbarPage {
	
	// --------------------------------------------------------------------
	// MARK: Wrapper properties
	// --------------------------------------------------------------------
	
	/// An array of pages managed by the tab bar coordinator.
	@Published public var pages: [Page] = []
	
	/// The currently selected page in the tab bar.
	@Published public var currentPage: Page
	
	// --------------------------------------------------------------------
	// MARK: Properties
	// --------------------------------------------------------------------
	
	/// The transition presentation style used by the tab bar coordinator.
	private var presentationStyle: TransitionPresentationStyle
	
	
	public var setBadge: PassthroughSubject<(String?, Page), Never> = .init()
	
	var customView: Page.View?
	
	// ---------------------------------------------------------
	// MARK: Constructor
	// ---------------------------------------------------------
	
	/**
		 Initializes a new tab bar coordinator with the specified pages, current page, and presentation style.

		 Example usage:
		 ```swift
		 let tabbarCoordinator = TabbarCoordinator(
			 pages: myPages,
			 currentPage: initialPage,
			 presentationStyle: .sheet
		 )
		 ```

		 - Parameters:
			- pages: An array of pages managed by the tab bar coordinator.
			- currentPage: The initially selected page in the tab bar.
			- presentationStyle: The transition presentation style used by the tab bar coordinator.
			- parent: The parent coordinator, if any. Default is nil.
	*/
	public init(
		pages: [Page],
		currentPage: Page,
		presentationStyle: TransitionPresentationStyle = .sheet,
		customView: Page.View? = nil
	) {
		self.presentationStyle = presentationStyle
		self.currentPage = currentPage
		self.customView = customView
		super.init()
		setPages(pages, currentPage: currentPage, completion: nil)
	}
	
	// ---------------------------------------------------------
	// MARK: Coordinator
	// --------------------------------------------------------
	
	/**
		Starts the tab bar coordinator, triggering any necessary setup.

		Example usage:
		```swift
		tabbarCoordinator.start()
		```

		- Parameters:
		   - animated: A flag indicating whether the start should be animated. Default is true.
	*/
    open override func start(animated: Bool = true, completion: Completion? = nil) {
        let route = RouteBase(
            presentationStyle: presentationStyle,
            content: customView ?? TabbarCoordinatorView(viewModel: self)
        )
        
        return startFlow(
            route: route,
            transitionStyle: presentationStyle,
            animated: animated,
            completion: completion)
	}
	
	// ---------------------------------------------------------
	// MARK: Helper funcs
	// ---------------------------------------------------------
	
	/**
		 Retrieves the currently selected coordinator.

		 Example usage:
		 ```swift
		 let selectedCoordinator = try tabbarCoordinator.getCoordinatorSelected()
		 ```

		 - Returns: The currently selected coordinator.
		 - Throws: An error if the coordinator cannot be retrieved.
	*/
	open func getCoordinatorSelected() throws -> (any CoordinatorType) {
		guard let index = children.firstIndex(where: { $0.tagId == "\(currentPage.position)" })
		else { throw TabbarCoordinatorError.coordinatorSelected }
		return children[index]
	}
	
	/**
		 Sets the pages for the tab bar coordinator with optional completion.

		 Example usage:
		 ```swift
		 tabbarCoordinator.setPages(myNewPages) {
			 // Completion block after setting new pages
		 }
		 ```

		 - Parameters:
			- values: The new array of pages to set for the tab bar coordinator.
			- currentPage: The new currently selected page. Default is nil.
			- completion: A closure to be executed after setting the new pages. Default is nil.
	*/
	open func setPages(_ values: [Page], currentPage: Page? = nil, completion: (() -> Void)? = nil) {
		handleUpdatePages(currentPage: currentPage) { [weak self] in
			self?.setupPages(values)
			self?.pages = values
			self?.setCurrentPage(currentPage)
            completion?()
		}
	}
	
	/**
		Sets up the initial pages for the tab bar coordinator.

		Example usage:
		```swift
		tabbarCoordinator.setupPages(myInitialPages)
		```

		- Parameters:
		   - value: The initial array of pages to set up for the tab bar coordinator.
	*/
	private func setupPages(_ value: [Page]) {
		value.forEach({
			let item = $0.coordinator()
			startChildCoordinator(item)
			item.tagId = "\($0.position)"
		})
	}
	
	/**
		 Retrieves the coordinator associated with a specific position in the tab bar.

		 Example usage:
		 ```swift
		 let coordinator = tabbarCoordinator.getView(from: 1)
		 ```

		 - Parameters:
			- position: The position of the page in the tab bar.
		 - Returns: The coordinator associated with the specified position, or nil if not found.
	*/
	public func getCoordinator(with position: Int) -> (any CoordinatorType)? {
		children.first(where: {
			$0.tagId == "\(position)"
		})
	}
	
	// ---------------------------------------------------------------------
	// MARK: Private helper funcs
	// ---------------------------------------------------------------------
	
	/**
		 Sets the current page for the tab bar coordinator.

		 Example usage:
		 ```swift
		 tabbarCoordinator.setCurrentPage(myNewPage)
		 ```

		 - Parameters:
			- value: The new currently selected page for the tab bar coordinator.
	*/
	private func setCurrentPage(_ value: (any TabbarPage)?) {
		guard let value, value.position != currentPage.position,
			  let item = pages.first(where: { $0.position == value.position })
		else { return  }
		
		currentPage = item
	}
	
	/**
		 Handles updates to the pages with optional completion.

		 Example usage:
		 ```swift
		 tabbarCoordinator.handleUpdatePages(currentPage: myNewPage) {
			 // Completion block after updating pages
		 }
		 ```

		 - Parameters:
			- currentPage: The new currently selected page. Default is nil.
			- completion: A closure to be executed after updating the pages. Default is nil.
	*/
	private func handleUpdatePages(
		currentPage: Page? = nil,
		completion: (() -> Void)? = nil
	) {
		removeChildren(completion)
	}
}
