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
///
/// `TabCoordinator` provides a complete implementation of tab-based navigation that manages
/// multiple child coordinators, each representing a separate navigation flow within a tab.
/// It handles page transitions, badge management, and coordination between the tab interface
/// and individual tab content.
///
/// ## Key Features
/// - **Multi-tab Navigation**: Manages multiple independent navigation flows
/// - **Badge Support**: Provides badge notifications for individual tabs
/// - **Custom Views**: Supports custom tab interface implementations via `viewContainer`
/// - **Child Coordinator Management**: Automatically manages lifecycle of child coordinators
/// - **SwiftUI Integration**: Seamlessly integrates with SwiftUI's navigation system
///
/// ## Usage
///
/// Create a tab coordinator by defining your pages and providing a view container:
///
/// ```swift
/// let tabCoordinator = TabCoordinator(
///     pages: [.home, .profile, .settings],
///     currentPage: .home,
///     viewContainer: { coordinator in
///         TabViewCoordinator(dataSource: coordinator, currentPage: coordinator.currentPage)
///     }
/// )
/// ```
///
/// Each page should conform to `TabPage` and provide its own coordinator:
///
/// ```swift
/// enum MyPage: TabPage {
///     case home, profile, settings
///     
///     func coordinator() -> any CoordinatorType {
///         switch self {
///         case .home: return HomeCoordinator()
///         case .profile: return ProfileCoordinator()
///         case .settings: return SettingsCoordinator()
///         }
///     }
/// }
/// ```
///
/// ## Badge Management
///
/// Set badges on tabs using the `setBadge` publisher:
///
/// ```swift
/// tabCoordinator.setBadge.send(("3", .profile)) // Show badge with "3"
/// tabCoordinator.setBadge.send((nil, .profile)) // Remove badge
/// ```
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
    /// Changes to this array will automatically update the tab interface.
    @Published public var pages: [Page] = []
    
    /// The published current page associated with the tab coordinator.
    ///
    /// This property tracks which tab is currently selected and active. Updates to this
    /// property will trigger tab selection changes in the interface.
    @Published public var currentPage: Page
    
    // --------------------------------------------------------------------
    // MARK: CoordinatorType properties
    // --------------------------------------------------------------------
    
    /// The unique identifier for the coordinator.
    public var uuid: String
    
    /// The parent coordinator associated with the coordinator.
    ///
    /// This represents the coordinator that presented or contains this tab coordinator.
    public var parent: (any CoordinatorType)?
    
    /// The array of children coordinators associated with the coordinator.
    ///
    /// Each child coordinator corresponds to a tab and manages the navigation flow for that tab.
    /// The `tagId` of each child coordinator matches the position of its corresponding page.
    public var children: [(any CoordinatorType)] = []
    
    /// The tag identifier associated with the coordinator.
    ///
    /// This identifier is used to uniquely identify the coordinator within its parent's children array.
    public var tagId: String?
    
    // --------------------------------------------------------------------
    // MARK: TabCoordinatorType properties
    // --------------------------------------------------------------------
    
    /// The presentation style for the tab coordinator itself.
    ///
    /// This defines how the tab coordinator is presented when started (e.g., as a sheet,
    /// full screen cover, etc.). This is different from the navigation within individual tabs.
    private var presentationStyle: TransitionPresentationStyle
    
    /// A subject for setting badge values on specific tabs.
    ///
    /// Use this subject to asynchronously update badge values for individual tabs.
    /// Send a tuple containing the badge value (or nil to remove) and the target page.
    public let badge: PassthroughSubject<(String?, Page), Never>
    
    /// A closure that provides the custom view container for the tab interface.
    ///
    /// This closure receives the `TabCoordinator` instance and returns a view that implements
    /// the tab interface. If you want to use the default tab view, provide `TabViewCoordinator`.
    /// For custom tab interfaces, implement your own view that conforms to the expected interface.
    public var viewContainer: (TabCoordinator<Page>) -> (Page.View)
    
    
    // ---------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------
    
    /// Initializes a new instance of `TabCoordinator`.
    ///
    /// - Parameters:
    ///   - pages: The array of pages for the tab coordinator. Each page represents a tab and
    ///           should provide its own coordinator through the `coordinator()` method.
    ///   - currentPage: The initial current page for the tab coordinator. This tab will be
    ///                 selected by default when the coordinator starts.
    ///   - presentationStyle: The presentation style for the tab coordinator itself.
    ///                       Defaults to `.sheet`. This controls how the entire tab interface
    ///                       is presented, not the navigation within individual tabs.
    ///   - viewContainer: A closure that provides the view container for the tab interface.
    ///                   This closure receives the coordinator instance and should return
    ///                   a view that implements the tab interface.
    ///
    /// - Note: Make sure each page's `coordinator()` method returns a properly configured
    ///         coordinator. The `tagId` of each child coordinator will be automatically set
    ///         to match the position of its corresponding page.
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
    // --------------------------------------------------------
    
    /// Starts the tab coordinator and presents the tab interface.
    ///
    /// This method initializes all child coordinators for the provided pages, sets up
    /// the tab interface, and presents it using the specified presentation style.
    /// Each page's coordinator is created and properly configured with the correct `tagId`.
    ///
    /// - Parameters:
    ///   - animated: A boolean value indicating whether to animate the presentation.
    ///              Defaults to `true`.
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
    
    /// Retrieves the coordinator at a specific position within the tab coordinator.
    ///
    /// This method searches through the child coordinators to find one with a `tagId`
    /// that matches the specified position converted to a string.
    ///
    /// - Parameters:
    ///   - position: The zero-based position of the coordinator to retrieve.
    /// - Returns: The coordinator at the specified position, or `nil` if no coordinator
    ///           is found at that position.
    public func getCoordinator(with page: Page) -> AnyCoordinatorType? {
        children.first { $0.tagId == page.id }
    }
    
    /// Retrieves the currently selected coordinator within the tab coordinator.
    ///
    /// This method finds the child coordinator that corresponds to the currently active tab
    /// by matching the current page's position with the coordinator's `tagId`.
    ///
    /// - Returns: The coordinator that corresponds to the currently selected tab.
    /// - Throws: `TabCoordinatorError.coordinatorSelected` if the selected coordinator
    ///          cannot be found. This can happen if the current page's position doesn't
    ///          match any child coordinator's `tagId`.
    open func getCoordinatorSelected() throws -> (any CoordinatorType) {
        guard let index = children.firstIndex(where: { $0.tagId == "\(currentPage.id)" })
        else { throw TabCoordinatorError.coordinatorSelected }
        return children[index]
    }
    
    public func setBadge(for page: Page, with value: String?) {
        badge.send((value, page))
    }
    
    /// Performs cleanup operations for the tab coordinator.
    ///
    /// This method clears all pages, cleans up the router, and releases resources.
    /// It should be called when the tab coordinator is no longer needed to prevent
    /// memory leaks and ensure proper cleanup of all child coordinators.
    ///
    /// The cleanup process:
    /// 1. Clears all pages and resets the current page
    /// 2. Cleans up the router and dismisses any presented views
    /// 3. Releases references to child coordinators
    @MainActor public func clean() async {
        await setPages([], currentPage: nil)
        await router.clean(animated: false)
    }
}