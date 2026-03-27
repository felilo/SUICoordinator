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

    public var router: RouterType<DefaultRoute> = Router()
    public var pages: [Page] = []
    public var parent: CoordinatorType?
    public var children: [CoordinatorType] = []
    public var tagId: String?
    public var uuid: String = UUID().uuidString

    // --------------------------------------------------------------------
    // MARK: TabCoordinatorType properties
    // --------------------------------------------------------------------

    public var badges: AsyncStream<(String?, Page)> { stream }

    // --------------------------------------------------------------------
    // MARK: Private backing storage (nonisolated let — safe from any context)
    // --------------------------------------------------------------------

    /// Backing storage initialized once in `init`; `uuid`, `currentPage`, and `viewContainer`
    /// are exposed as computed properties so that the stored values are plain `let` constants,
    /// which Swift permits writing from a `nonisolated` context.
    @ObservationIgnored private let _presentationStyle: TransitionPresentationStyle
    @ObservationIgnored private let _initialPages: [Page]
    @ObservationIgnored private let _initialCurrentPage: Page
    @ObservationIgnored private let _viewContainer: @MainActor @Sendable (TabCoordinator<Page>) -> Page.View
    private let (stream, continuation) = AsyncStream.makeStream(of: (String?, Page).self)

    // Mutable current-page is the only `var` that needs @MainActor isolation.
    // It is stored separately so `nonisolated init` never touches it.
    private var _currentPage: Page?

    // ---------------------------------------------------------
    // MARK: TabCoordinatorType computed wrappers
    // ---------------------------------------------------------

    

    public var currentPage: Page {
        get { _currentPage ?? _initialCurrentPage }
        set { _currentPage = newValue }
    }

    public var viewContainer: @MainActor @Sendable (TabCoordinator<Page>) -> Page.View {
        get { _viewContainer }
    }

    // ---------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------

    public nonisolated init(
        pages: [Page],
        currentPage: Page,
        presentationStyle: TransitionPresentationStyle = .sheet,
        viewContainer: @escaping @MainActor @Sendable (TabCoordinator<Page>) -> Page.View
    ) {
        self._presentationStyle = presentationStyle
        self._initialPages = pages
        self._initialCurrentPage = currentPage
        self._viewContainer = viewContainer
        defer { Task { [weak self] in await self?.start() } }
    }

    // ---------------------------------------------------------
    // MARK: Coordinator
    // ---------------------------------------------------------

    open func start() async {
        guard !isRunning else { return }
        await setupPages(_initialPages, currentPage: _initialCurrentPage)
        let cView = _viewContainer
        await startFlow(
            route: .init(
                presentationStyle: _presentationStyle,
                content: { cView(self) }
            )
        )
    }

    // ---------------------------------------------------------
    // MARK: Helper funcs
    // ---------------------------------------------------------

    public func getCoordinator(with page: Page) -> CoordinatorType? {
        children.first { $0.tagId == page.id }
    }

    open func getCoordinatorSelected() throws -> CoordinatorType {
        guard let index = children.firstIndex(where: { $0.tagId == "\(currentPage.id)" })
        else { throw TabCoordinatorError.coordinatorSelected }
        return children[index]
    }

    public func setBadge(for page: Page, with value: String?) {
        continuation.yield((value, page))
    }

    public func clean() async {
        await setPages([], currentPage: nil)
        await router.clean(animated: false, withMainView: true)
    }
}

