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

/// An open class representing a coordinator for managing a tabbar-based navigation.
///
/// Tabbar coordinators handle the navigation and coordination of pages within a tabbar.
open class TabbarCoordinator<Page>: Coordinator<RouteBase>, TabbarCoordinatorType where Page: TabbarPage {
    
    // --------------------------------------------------------------------
    // MARK: Wrapper properties
    // --------------------------------------------------------------------
    
    /// The array of published pages associated with the tabbar coordinator.
    @Published public var pages: [Page] = []
    
    /// The published current page associated with the tabbar coordinator.
    @Published public var currentPage: Page
    
    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------
    
    /// The presentation style for transitioning between pages.
    private var presentationStyle: TransitionPresentationStyle
    
    /// A subject for setting badge values.
    public var setBadge: PassthroughSubject<(String?, Page), Never> = .init()
    
    /// A custom view associated with the tabbar coordinator.
    var customView: Page.View?
    
    // ---------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------
    
    /// Initializes a new instance of `TabbarCoordinator`.
    ///
    /// - Parameters:
    ///   - pages: The array of pages associated with the tabbar coordinator.
    ///   - currentPage: The initial current page for the tabbar coordinator.
    ///   - presentationStyle: The presentation style for transitioning between pages.
    ///   - customView: A custom view associated with the tabbar coordinator.
    public init( pages: [Page], currentPage: Page, presentationStyle: TransitionPresentationStyle = .sheet, customView: Page.View? = nil) {
        self.presentationStyle = presentationStyle
        self.currentPage = currentPage
        self.customView = customView
        super.init()
        
        Task { [weak self] in
            await self?.setPages(pages, currentPage: currentPage)
        }
        
    }
    
    // ---------------------------------------------------------
    // MARK: Coordinator
    // --------------------------------------------------------
    
    /// Starts the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the start process.
    open override func start(animated: Bool = true) async {
        let route = RouteBase(
            presentationStyle: presentationStyle,
            content: customView ?? TabbarCoordinatorView(viewModel: self)
        )
        
        await startFlow(
            route: route,
            transitionStyle: presentationStyle,
            animated: animated)
    }
    
    // ---------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------
    
    /// Retrieves the selected coordinator within the tabbar coordinator.
    ///
    /// - Returns: The selected coordinator.
    open func getCoordinatorSelected() throws -> (any CoordinatorType) {
        guard let index = children.firstIndex(where: { $0.tagId == "\(currentPage.position)" })
        else { throw TabbarCoordinatorError.coordinatorSelected }
        return children[index]
    }
    
    /// Sets the array of pages for the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - values: The array of pages to set.
    ///   - currentPage: The optional current page to set.
    open func setPages(_ values: [Page], currentPage: Page? = nil) async {
        await removeChildren()
        setupPages(values)
        pages = values
        setCurrentPage(currentPage)
    }
    
    /// Sets up the pages for the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - value: The array of pages to set up.
    private func setupPages(_ value: [Page]) {
        value.forEach({
            let item = $0.coordinator()
            startChildCoordinator(item)
            item.tagId = "\($0.position)"
        })
    }
    
    /// Retrieves the coordinator at a specific position within the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - position: The position of the coordinator.
    /// - Returns: The coordinator at the specified position.
    public func getCoordinator(with position: Int) -> (any CoordinatorType)? {
        children.first(where: {
            $0.tagId == "\(position)"
        })
    }
    
    // ---------------------------------------------------------------------
    // MARK: Private helper funcs
    // ---------------------------------------------------------------------
    
    /// Sets the current page for the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - value: The optional current page to set.
    private func setCurrentPage(_ value: (any TabbarPage)?) {
        guard let value, value.position != currentPage.position,
              let item = pages.first(where: { $0.position == value.position })
        else { return  }
        
        currentPage = item
    }
}
