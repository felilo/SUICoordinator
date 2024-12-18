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
open class TabbarCoordinator<Page: TabbarPage>: TabbarCoordinatable {
    
    // --------------------------------------------------------------------
    // MARK: Wrapper properties
    // --------------------------------------------------------------------
    
    /// The published router associated with the coordinator.
    @Published public var router: Router<DefaultRoute>
    
    /// The array of published pages associated with the tabbar coordinator.
    @Published public var pages: [Page] = []
    
    /// The published current page associated with the tabbar coordinator.
    @Published public var currentPage: Page
    
    // --------------------------------------------------------------------
    // MARK: CoordinatorType properties
    // --------------------------------------------------------------------
    
    /// The unique identifier for the coordinator.
    public var uuid: String
    
    /// The parent coordinator associated with the coordinator.
    public var parent: (any CoordinatorType)!
    
    /// The array of children coordinators associated with the coordinator.
    public var children: [(any CoordinatorType)] = []
    
    /// The tag identifier associated with the coordinator.
    public var tagId: String?
    
    // --------------------------------------------------------------------
    // MARK: TabbarCoordinatorType properties
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
        self.router = .init()
        self.uuid = "\(NSStringFromClass(type(of: self))) - \(UUID().uuidString)"
        self.presentationStyle = presentationStyle
        self.currentPage = currentPage
        self.customView = customView
        self.pages = pages
        
        router.isTabbarCoordinable = true
    }
    
    // ---------------------------------------------------------
    // MARK: Coordinator
    // --------------------------------------------------------
    
    /// Starts the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the start process.
    open func start(animated: Bool = true) async {
        await setupPages(pages, currentPage: currentPage)
        
        let cView = customView?() ?? TabbarCoordinatorView(dataSource: self, currentPage: currentPage)
        
        await startFlow(
            route: DefaultRoute(presentationStyle: presentationStyle) { cView },
            transitionStyle: presentationStyle,
            animated: animated)
    }
    
    // ---------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------
    
    /// Retrieves the coordinator at a specific position within the tabbar coordinator.
    ///
    /// - Parameters:
    ///   - position: The position of the coordinator.
    /// - Returns: The coordinator at the specified position.
    public func getCoordinator(with position: Int) -> (any CoordinatorType)? {
        children.first { $0.tagId == "\(position)" }
    }
    
    /// Retrieves the selected coordinator within the tabbar coordinator.
    ///
    /// - Returns: The selected coordinator.
    open func getCoordinatorSelected() throws -> (any CoordinatorType) {
        guard let index = children.firstIndex(where: { $0.tagId == "\(currentPage.position)" })
        else { throw TabbarCoordinatorError.coordinatorSelected }
        return children[index]
    }
    
    @MainActor public func clean() async {
        await setPages([], currentPage: nil)
        await router.clean(animated: false)
        router = .init()
        customView = nil
    }
}
