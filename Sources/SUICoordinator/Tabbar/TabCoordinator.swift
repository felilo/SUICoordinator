//
//  TabCoordinator.swift
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

import Combine
import Foundation

/// A coordinator class for managing tab-based navigation in SwiftUI applications.
@available(iOS 17.0, *)
@Observable
open class TabCoordinator<Page: TabPage>: TabCoordinatable {
    
    // --------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------
    
    public var router: Router<DefaultRoute>
    public var pages: [Page] = []
    public var currentPage: Page
    public var uuid: String
    public var parent: (any CoordinatorType)?
    public var children: [(any CoordinatorType)] = []
    public var tagId: String?
    
    // --------------------------------------------------------------------
    // MARK: TabCoordinatorType properties
    // --------------------------------------------------------------------
    
    private var presentationStyle: TransitionPresentationStyle
    public let badge: PassthroughSubject<(String?, Page), Never>
    public var viewContainer: (TabCoordinator<Page>) -> (Page.View)
    
    // ---------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------
    
    public init(
        pages: [Page],
        currentPage: Page,
        presentationStyle: TransitionPresentationStyle = .sheet,
        viewContainer: @escaping (TabCoordinator<Page>) -> Page.View
    ) {
        defer { Task { [weak self] in await self?.start() } }
        
        self.router = .init()
        self.uuid = "\(NSStringFromClass(type(of: self))) - \(UUID().uuidString)"
        self.presentationStyle = presentationStyle
        self.currentPage = currentPage
        self.viewContainer = viewContainer
        self.pages = pages
        self.badge = .init()
    }
    
    // ---------------------------------------------------------
    // MARK: Coordinator
    // ---------------------------------------------------------
    
    open func start() async {
        guard !isRunning else { return }
        await setupPages(pages, currentPage: currentPage)
        let cView = viewContainer
        await startFlow(
            route: .init(
                presentationStyle: presentationStyle,
                content: { cView(self) }
            )
        )
    }
    
    // ---------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------
    
    public func getCoordinator(with page: Page) -> AnyCoordinatorType? {
        children.first { $0.tagId == page.id }
    }
    
    open func getCoordinatorSelected() throws -> (any CoordinatorType) {
        guard let index = children.firstIndex(where: { $0.tagId == "\(currentPage.id)" })
        else { throw TabCoordinatorError.coordinatorSelected }
        return children[index]
    }
    
    public func setBadge(for page: Page, with value: String?) {
        badge.send((value, page))
    }
    
    @MainActor public func clean() async {
        await setPages([], currentPage: nil)
        await router.clean(animated: false)
    }
}
