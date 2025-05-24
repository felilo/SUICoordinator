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

/// An open class representing a coordinator for managing tab-based navigation.
///
/// `TabCoordinator` handles the navigation and coordination of pages within a tab interface.
/// It manages child coordinators for each tab, handles page transitions, and provides
/// badge management functionality.
///
/// Each tab is represented by a `TabPage` and has an associated child coordinator that
/// manages the navigation flow for that specific tab.
open class TabCoordinator<Page: TabPage>: TabCoordinatable {
    
    // --------------------------------------------------------------------
    // MARK: Wrapper properties
    // --------------------------------------------------------------------
    
    /// The published router associated with the tab coordinator.
    ///
    /// This router handles the presentation and navigation logic for the tab coordinator itself.
    @Published public var router: Router<DefaultRoute>
    
    /// The array of published pages associated with the tab coordinator.
    ///
    /// This array contains all the available tabs that can be displayed in the tab interface.
    @Published public var pages: [Page] = []
    
    /// The published current page associated with the tab coordinator.
    ///
    /// This property tracks which tab is currently selected and active.
    @Published public var currentPage: Page
    
    // --------------------------------------------------------------------
    // MARK: CoordinatorType properties
    // --------------------------------------------------------------------
    
    /// The unique identifier for the coordinator.
    public var uuid: String
    
    /// The parent coordinator associated with the coordinator.
    ///
    /// This represents the coordinator that presented or contains this tab coordinator.
    public var parent: (any CoordinatorType)!
    
    /// The array of children coordinators associated with the coordinator.
    ///
    /// Each child coordinator corresponds to a tab and manages the navigation flow for that tab.
    /// The `tagId` of each child coordinator should match the position of its corresponding page.
    public var children: [(any CoordinatorType)] = []
    
    /// The tag identifier associated with the coordinator.
    ///
    /// This identifier is used to uniquely identify the coordinator within its parent's children array.
    public var tagId: String?
    
    // --------------------------------------------------------------------
    // MARK: TabCoordinatorType properties
    // --------------------------------------------------------------------
    
    /// The presentation style for transitioning between pages.
    ///
    /// This defines how the tab coordinator itself is presented (e.g., as a sheet, full screen cover, etc.).
    private var presentationStyle: TransitionPresentationStyle
    
    /// A subject for setting badge values on specific tabs.
    ///
    /// Use this subject to asynchronously update badge values for individual tabs.
    /// Send a tuple containing the badge value (or nil to remove) and the target page.
    public var setBadge: PassthroughSubject<(String?, Page), Never> = .init()
    
    /// A custom view associated with the tab coordinator.
    ///
    /// If provided, this custom view will be used instead of the default `TabViewCoordinator`.
    /// This allows for complete customization of the tab interface appearance and behavior.
    public var customView: (() -> (Page.View?))?
    
    // ---------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------
    
    /// Initializes a new instance of `TabCoordinator`.
    ///
    /// - Parameters:
    ///   - pages: The array of pages associated with the tab coordinator. Each page represents a tab.
    ///   - currentPage: The initial current page for the tab coordinator. This tab will be selected by default.
    ///   - presentationStyle: The presentation style for transitioning between pages. Defaults to `.sheet`.
    ///   - customView: A custom view associated with the tab coordinator. If nil, uses the default tab view.
    ///
    /// - Note: Make sure to set the `tagId` of each child coordinator to match the position of its corresponding page.
    public init(
        pages: [Page],
        currentPage: Page,
        presentationStyle: TransitionPresentationStyle = .sheet,
        customView: (() -> Page.View?)? = nil
    ) {
        self.router = .init()
        self.uuid = "\(NSStringFromClass(type(of: self))) - \(UUID().uuidString)"
        self.presentationStyle = presentationStyle
        self.currentPage = currentPage
        self.customView = customView
        self.pages = pages
        
        router.isTabCoordinable = true
    }
    
    // ---------------------------------------------------------
    // MARK: Coordinator
    // --------------------------------------------------------
    
    /// Starts the tab coordinator.
    ///
    /// This method sets up the tab pages and their associated coordinators, then presents
    /// the tab interface using either a custom view or the default `TabViewCoordinator`.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the start process. Defaults to `true`.
    open func start(animated: Bool = true) async {
        setupPages(pages, currentPage: currentPage)
        
        let cView = customView?() ?? TabViewCoordinator(dataSource: self, currentPage: currentPage)
        
        await startFlow(
            route: DefaultRoute(presentationStyle: presentationStyle) { cView },
            transitionStyle: presentationStyle,
            animated: animated)
    }
    
    // ---------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------
    
    /// Retrieves the coordinator at a specific position within the tab coordinator.
    ///
    /// This method searches through the child coordinators to find one with a `tagId`
    /// that matches the specified position.
    ///
    /// - Parameters:
    ///   - position: The position of the coordinator to retrieve.
    /// - Returns: The coordinator at the specified position, or `nil` if no coordinator is found.
    public func getCoordinator(with position: Int) -> (any CoordinatorType)? {
        children.first { $0.tagId == "\(position)" }
    }
    
    /// Retrieves the currently selected coordinator within the tab coordinator.
    ///
    /// This method finds the child coordinator that corresponds to the currently active tab.
    ///
    /// - Returns: The coordinator that corresponds to the currently selected tab.
    /// - Throws: `TabCoordinatorError.coordinatorSelected` if the selected coordinator cannot be found.
    open func getCoordinatorSelected() throws -> (any CoordinatorType) {
        guard let index = children.firstIndex(where: { $0.tagId == "\(currentPage.position)" })
        else { throw TabCoordinatorError.coordinatorSelected }
        return children[index]
    }
    
    /// Performs cleanup operations for the tab coordinator.
    ///
    /// This method clears all pages, cleans up the router, and releases the custom view.
    /// It should be called when the tab coordinator is no longer needed to free up resources.
    @MainActor public func clean() async {
        await setPages([], currentPage: nil)
        await router.clean(animated: false)
        customView = nil
    }
}
