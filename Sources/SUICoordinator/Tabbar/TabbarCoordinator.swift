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
open class TabbarCoordinator<Page: TabbarPage>: TabbarCoordinatorType {
    
    // --------------------------------------------------------------------
    // MARK: Wrapper properties
    // --------------------------------------------------------------------
    
    /// The array of published pages associated with the tabbar coordinator.
    @Published public var pages: [Page] = []
    
    /// The published current page associated with the tabbar coordinator.
    @Published public var currentPage: Page
    
    // --------------------------------------------------------------------
    // MARK: Properties
    // MARK: Properties
    // MARK: Properties
    // --------------------------------------------------------------------
    
    /// The presentation style for transitioning between pages.
    private var presentationStyle: TransitionPresentationStyle
    
    /// A subject for setting badge values.
    public var setBadge: PassthroughSubject<(String?, Page), Never> = .init()
    
    /// A custom view associated with the tabbar coordinator.
    public var customView: (() -> (Page.View))?
    
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
    public init(
        pages: [Page],
        currentPage: Page,
        presentationStyle: TransitionPresentationStyle = .sheet,
        customView: (() -> Page.View)? = nil
    ) {
        self.presentationStyle = presentationStyle
        self.currentPage = currentPage
        self.customView = customView
        self.pages = pages
        
        super.init()
    }
    
    // ---------------------------------------------------------
    // MARK: Coordinator
    // --------------------------------------------------------
    
    /// Starts the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the start process.
    open override func start(animated: Bool = true) async {
        await setupPages(pages, currentPage: currentPage)
        
        let cView = customView?() ?? TabbarCoordinatorView(viewModel: self, currentPage: currentPage)
        
        await startFlow(
            route: DefaultRoute(presentationStyle: presentationStyle) { cView },
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
        await setupPages(values, currentPage: currentPage)
    }
    
    /// Retrieves the coordinator at a specific position within the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - position: The position of the coordinator.
    /// - Returns: The coordinator at the specified position.
    open func getCoordinator(with position: Int) -> (any CoordinatorType)? {
        children.first { $0.tagId == "\(position)" }
    }
    
    /// Sets up the pages for the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - value: The array of pages to set up.
    @MainActor private func setupPages(_ value: [Page], currentPage: Page? = nil) {
        for page in value {
            let item = page.coordinator()
            startChildCoordinator(item)
            item.tagId = "\(page.position)"
        }
        
        pages = value
        setCurrentPage(currentPage)
    }
}
