# SUICoordinator

A comprehensive SwiftUI coordinator pattern library that provides powerful navigation management and tab-based coordination for iOS applications. SUICoordinator enables clean separation of concerns by decoupling navigation logic from view presentation, making your SwiftUI apps more maintainable and scalable.

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![iOS 16.0+](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/Framework-SwiftUI-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

_____

## Key Features

- **Pure SwiftUI**: No UIKit dependencies - built entirely with SwiftUI
- **Coordinator Pattern**: Clean separation of navigation logic from views
- **Tab Coordination**: Advanced tab-based navigation with `TabCoordinator`, custom views, and badges
- **Flexible Presentations**: Support for push, sheet, fullscreen, detents, and custom presentations
- **Deep Linking**: Force presentation capabilities for push notifications and external triggers
- **Type-Safe Routes**: Strongly typed navigation routes with compile-time safety
- **Async Navigation**: Full async/await support for smooth navigation flows
- **Custom Tab Bars**: Create completely custom tab interfaces with `TabCoordinator`
- **Badge Support**: Dynamic badge management for tab items in `TabCoordinator`
- **Memory Management**: Automatic cleanup and resource management

_____

## Quick Start

### Installation

#### Swift Package Manager

1. Open Xcode and your project
2. Go to `File` → `Swift Packages` → `Add Package Dependency...`
3. Enter the repository URL: `https://github.com/felilo/SUICoordinator`
4. Click `Next` twice and then `Finish`

#### Manual Installation

1. Download the source files from the `Sources/SUICoordinator` directory.
2. Drag and drop the `SUICoordinator` folder into your Xcode project.
3. Make sure to add it to your target.

_____

## Basic Usage

### 1. Define Your Routes
Create an enum that conforms to `RouteType` to define your navigation paths and their associated views.

```swift
import SwiftUI
import SUICoordinator

enum HomeRoute: RouteType {
    case push(viewModel: PushViewModel)
    case sheet(viewModel: SheetViewModel)
    case actionListView(viewModel: ActionListViewModel)
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
            case .push: .push
            case .sheet: .sheet
            case .actionListView: .push
        }
    }

    @ViewBuilder
    var view: Body { // Body is an alias for 'any View'
        switch self {
            case .push(let viewModel): PushView(viewModel: viewModel)
            case .sheet(let viewModel): SheetView(viewModel: viewModel)
            case .actionListView(let viewModel): NavigationActionListView(viewModel: viewModel)
        }
    }
}
```

### 2. Create Your Coordinator
Subclass `Coordinator<YourRouteType>` and implement the mandatory `start()` method. This method defines the initial view or flow for the coordinator.

```swift
import SUICoordinator

class HomeCoordinator: Coordinator<HomeRoute> {
    
    override func start(animated: Bool = true) async {
        // This is the first view the coordinator will show.
        // 'startFlow' clears any existing navigation stack and presents this route.
        let viewModel = ActionListViewModel(coordinator: self)
        await startFlow(route: .actionListView(viewModel: viewModel), animated: animated)
    }
    
    // Example: Navigating to another view within this coordinator's flow
    func navigateToPushView() async {
        let viewModel = PushViewModel(coordinator: self)
        // Use the 'router' to navigate to other routes defined in HomeRoute.
        await router.navigate(toRoute: .push(viewModel: viewModel))
    }
    
    // Example: Presenting a sheet
    func presentSheet() async {
        let viewModel = SheetViewModel(coordinator: self)
        // Use 'presentSheet(route:)' for modal presentations.
        // The route's presentationStyle (e.g., .sheet, .fullScreenCover) will be used.
        await presentSheet(route: .sheet(viewModel: viewModel))
    }
    
    // Example: Navigating to another Coordinator (e.g., a TabCoordinator)
    func presentCustomTabs() async {
        let tabCoordinator = CustomAppTabCoordinator() // Assuming this is your TabCoordinator
        // The 'navigate(to:presentationStyle:)' method on a coordinator
        // is used to present another coordinator.
        await navigate(to: tabCoordinator, presentationStyle: .sheet)
    }
    
    func closeTopViewOrSheet() async {
        // 'router.close()' will either dismiss a presented sheet or pop a pushed view.
        await router.close(animated: true)
    }
    
    func endThisCoordinator() async {
        // 'finishFlow()' will dismiss/pop all views of this coordinator
        // and remove it from its parent coordinator.
        await finishFlow(animated: true)
    }
}
```

### 3. Define Views and ViewModels
Your SwiftUI views will typically be initialized with a ViewModel. The ViewModel can hold a reference to its coordinator to trigger navigation actions.

```swift
// ActionListViewModel.swift
import Foundation

class ActionListViewModel: ObservableObject {
    let coordinator: HomeCoordinator // Or a protocol if you prefer
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }
    
    @MainActor func userTappedPush() async {
        await coordinator.navigateToPushView()
    }
    
    @MainActor func userTappedShowSheet() async {
        await coordinator.presentSheet()
    }

    @MainActor func userTappedShowTabs() async {
        await coordinator.presentCustomTabs()
    }
}

// NavigationActionListView.swift
import SwiftUI

struct NavigationActionListView: View {
    @StateObject var viewModel: ActionListViewModel
    
    var body: some View {
        List {
            Button("Push Example View") { Task { await viewModel.userTappedPush() } }
            Button("Present Sheet Example") { Task { await viewModel.userTappedShowSheet() } }
            Button("Present Tab Coordinator") { Task { await viewModel.userTappedShowTabs() } }
        }
        .navigationTitle("Coordinator Actions")
    }
}
```

### 4. Setup in your App
In your main `App` struct, instantiate your root coordinator and use its `getView()` method.

```swift
import SwiftUI
import SUICoordinator // Import the library

@main
struct SUICoordinatorExampleApp: App {
    
    // Instantiate your main/root coordinator
    var mainCoordinator = HomeCoordinator() // Or your primary app coordinator
    
    var body: some Scene {
        WindowGroup {
            mainCoordinator.getView()
        }
    }
}
```


### How to  implement a TabView?
The `TabCoordinator<Page: TabPage>` is a specialized coordinator for managing a collection of child coordinators, where each child represents a distinct tab in a tab-based interface.

#### 1. Define Your Tab Pages (`TabPage`)
First, create an enum that conforms to `TabPage`. `TabPage` is a typealias for `PageDataSource & TabNavigationRouter & SCEquatable`.
- **`PageDataSource`**: Requires you to define:
    - `position: Int`: The order of the tab (0-indexed).
    - `dataSource: YourPageDataSourceType`: An object/struct that provides the tab's visual elements (e.g., icon, title).
- **`TabNavigationRouter`**: Requires you to implement:
    - `coordinator() -> any CoordinatorType`: A function that returns the specific `Coordinator` instance for this tab's navigation flow.
- **`SCEquatable`**: Enums conform to `Equatable` automatically if all their raw values/associated values do. This is usually satisfied.

```swift
import SwiftUI
import SUICoordinator

// Step 1.1: Define the data source for your tab items' appearance
// This struct will hold the data for icons and titles for each tab.
public struct AppTabPageDataSource {
    let page: AppTabPage // A reference to the AppTabPage enum case

    @ViewBuilder public var icon: some View {
        switch page {
            case .home: Image(systemName: "house.fill")
            case .settings: Image(systemName: "gearshape.fill")
        }
    }

    @ViewBuilder public var title: some View {
        switch page {
            case .home: Text("Home")
            case .settings: Text("Settings")
        }
    }
}

// Step 1.2: Define your TabPage enum
enum AppTabPage: TabPage, CaseIterable { // CaseIterable is useful for providing .allCases
    case home
    case settings

    // PageDataSource conformance
    var position: Int {
        switch self {
            case .home: return 0
            case .settings: return 1
        }
    }

    var dataSource: AppTabPageDataSource {
        // Return an instance of your data source for this page
        AppTabPageDataSource(page: self)
    }

    // TabNavigationRouter conformance
    func coordinator() -> any CoordinatorType {
        // Return the specific coordinator instance for this tab's flow
        switch self {
            case .home: return HomeCoordinator() // Create and return a new instance
            case .settings: return SettingsCoordinator() // Create and return a new instance
        }
    }
}
```
*Note: `HomeCoordinator` and `SettingsCoordinator` in the example above are regular `Coordinator` subclasses, each managing their own `RouteType` and views.*

#### 2. Create Your `TabCoordinator` Subclass
Subclass `TabCoordinator<YourTabPageEnum>`. In its initializer, you'll typically call `super.init()` providing:
- `pages`: An array of your `TabPage` enum cases (e.g., `AppTabPage.allCases.sorted(by: { $0.position < $1.position })`).
- `currentPage`: The `TabPage` case that should be selected initially.
- `presentationStyle` (optional): How this `TabCoordinator` itself is presented by its parent (default is `.sheet`).
- `viewContainer`: A closure that returns the SwiftUI view responsible for rendering the tab bar interface.
  - For SwiftUI's standard `TabView`, use `TabViewCoordinator(dataSource: $0, currentPage: $0.currentPage)`.
  - For a completely custom tab bar UI, provide your own SwiftUI view that takes the `TabCoordinator` instance (as `viewModel` or `dataSource`). See `CustomTabView.swift` in the example project.

```swift
// Example: TabCoordinator using SwiftUI's default TabView
import SUICoordinator

// Example: TabCoordinator using a custom TabView UI
// (See CustomTabView.swift and CustomTabCoordinator.swift in the example project for a full implementation)
class CustomAppTabCoordinator: TabCoordinator<AppTabPage> {
    init(initialPage: AppTabPage = .home) {
        super.init(
            pages: AppTabPage.allCases.sorted(by: { $0.position < $1.position }),
            currentPage: initialPage,
            viewContainer: { dataSource in
                // Provide your custom tab bar view.
                CustomTabView(dataSource: dataSource)
            }
        )
    }
}

// For a detailed example, you can view the [CustomTabView.swift](https://github.com/felilo/SUICoordinator/blob/main/Examples/SUICoordinatorExample/SUICoordinatorExample/Coordinators/CustomTabbar/CustomTabView.swift) implementation.

#### 3. Using the `TabCoordinator`
Instantiate and start your `TabCoordinator` from a parent coordinator, just like any other coordinator.

```swift
// In a parent coordinator (e.g., your main AppRootCoordinator)
func showMainApplicationTabs() async {
    let tabCoordinator = CustomAppTabCoordinator()
    // Present the TabCoordinator. '.fullScreenCover' is common for main tab interfaces.
    await navigate(to: tabCoordinator, presentationStyle: .fullScreenCover)
}
```

### Example project

For a comprehensive understanding and more advanced use cases, including `TabCoordinator` examples (both default SwiftUI `TabView` and custom tab views), please explore the example project located in the [Examples folder](https://github.com/felilo/SUICoordinator/tree/main/Examples/SUICoordinatorExample).

https://github.com/felilo/SUICoordinator/assets/10853689/90e8564e-6fa5-458b-b2a3-23d10f5aebb4

_____

### Features

These are the most important features and actions that you can perform:
<br>

#### RouteType
To create any route in `SUICoordinator`, your route definition (typically an `enum`) must conform to the `RouteType` protocol. This protocol is fundamental for defining navigable destinations within your application.

**Protocol Requirements:**

Conforming to `RouteType` (which also implies `SCHashable`) requires you to implement:

1.  **`presentationStyle: TransitionPresentationStyle`**:
    *   A computed property that returns a `TransitionPresentationStyle`.
    *   This determines how the view associated with the route will be presented. Possible values are:
        *   `.push`: For navigation stack presentation (e.g., within a `NavigationStack`).
        *   `.sheet`: Standard modal sheet presentation.
        *   `.fullScreenCover`: A modal presentation that covers the entire screen.
        *   `.detents(Set<PresentationDetent>)`: A sheet presentation that can rest at specific heights (detents like `.medium`, `.large`, or custom heights). Requires iOS 16+.
            *   Example: `.detents([.medium, .large])`
            *   Example: `.detents([.height(100), .fraction(0.75)])`
        *   `.custom(transition: AnyTransition, animation: Animation?, fullScreen: Bool = false)`: Allows for custom SwiftUI transitions.
            *   `transition`: The `AnyTransition` to use (e.g., `.slide`, `.opacity`, custom).
            *   `animation`: An optional `Animation` to apply to the transition.
            *   `fullScreen`: A `Bool` indicating if the custom transition should behave like a full-screen presentation (default `false`).

2.  **`view: Body`**:
    *   A computed property, annotated with `@ViewBuilder` and `@MainActor`.
    *   It must return a type conforming to `any View` (SwiftUI's `View` protocol). `Body` is a typealias for `any View` within `RouteType`.
    *   This property provides the actual SwiftUI view that will be displayed for this route.

**Example Implementation:**

```swift
import SwiftUI
import SUICoordinator

enum AppRoute: RouteType { // AppRoute now conforms to RouteType
    case login
    case dashboard(userId: String)
    case settings
    case itemDetails(itemId: String)
    case helpSheet
    case customTransitionView

    // 1. presentationStyle
    var presentationStyle: TransitionPresentationStyle {
        switch self {
            case .login:
                return .fullScreenCover // Login as a full screen cover
            case .dashboard, .itemDetails:
                return .push            // Dashboard and item details are pushed
            case .settings:
                return .sheet           // Settings are presented as a standard sheet
            case .helpSheet:
                if #available(iOS 16.0, *) { // .detents requires iOS 16+
                    return .detents([.medium, .large]) // Help sheet with detents
                } else {
                    return .sheet // Fallback for older iOS versions
                }
            case .customTransitionView:
                return .custom( // Example of a custom transition
                    transition: .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)),
                    animation: .easeInOut(duration: 0.5),
                    fullScreen: true
                )
        }
    }

    // 2. view
    @ViewBuilder @MainActor
    var view: Body { // Body is 'any View'
        switch self {
            case .login:
                LoginView() // Assuming LoginView exists
            case .dashboard(let userId):
                DashboardView(userId: userId) // Assuming DashboardView exists
            case .settings:
                SettingsView() // Assuming SettingsView exists
            case .itemDetails(let itemId):
                ItemDetailView(itemId: itemId) // Assuming ItemDetailView exists
            case .helpSheet:
                HelpView() // Assuming HelpView exists
            case .customTransitionView:
                MyCustomAnimatedView() // Assuming MyCustomAnimatedView exists
        }
    }
}
```

<br>

By defining routes this way, `SUICoordinator` can manage the presentation and lifecycle of your views in a type-safe and structured manner. The `SCHashable` conformance allows routes to be used in navigation stacks and for SwiftUI to differentiate between them.

You can also use `DefaultRoute` for generic views if you don't need a specific enum for routes, as demonstrated in the `TabFlowCoordinator` [example](https://github.com/felilo/SUICoordinator/blob/main/Examples/SUICoordinatorExample/SUICoordinatorExample/Coordinators/TabbarFlow/TabbarFlowCoordinator.swift).
<br>

#### Router
The `Router` (a property on every `Coordinator` instance, e.g., `coordinator.router`) is responsible for managing the navigation stack and modal presentations *for that specific coordinator*. It abstracts navigation details, allowing views and ViewModels to request navigation changes without knowing the underlying SwiftUI mechanisms.

<br>
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Parameters</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code style="color: blue;">navigate(toRoute:presentationStyle:animated:)</code></td>
      <td>
        <ul cellspacing="0" cellpadding="0">
          <li><b>toRoute:</b> <code>Route</code> (Your specific RouteType)</li>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code>, default: <code style="color: #ec6b6f;">nil</code> (uses route's default)</li>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Navigates to the given route. If the effective presentation style is <code>.push</code>, it pushes the view onto this router's navigation stack. Otherwise, it presents the view modally using this router's <code>sheetCoordinator</code>.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">present(_:presentationStyle:animated:)</code></td>
      <td>
        <ul>
          <li><b>_ view:</b> <code>Route</code> (Your specific RouteType)</li>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code>, default: <code style="color: #ec6b6f;">.sheet</code> (uses route's default if not .push, or .sheet if route's default is .push but a modal presentation is desired)</li>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Presents a view modally (e.g., sheet, fullScreenCover, detents) using this router's <code>sheetCoordinator</code>. If the presentation style is <code>.push</code>, it delegates to <code>navigate(toRoute:)</code>.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">pop(animated:)</code></td>
      <td>
        <ul>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Pops the top view from this router's navigation stack.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">popToRoot(animated:)</code></td>
      <td>
        <ul>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Pops all views on this router's navigation stack except its root view.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">popToView(_:animated:)</code></td>
      <td>
        <ul>
          <li><b>_ view:</b> <code>View.Type</code> (e.g., <code>MyView.self</code>)</li>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Pops views from this router's navigation stack until the specified view type is at the top.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">dismiss(animated:)</code></td>
      <td>
        <ul>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Dismisses the top-most modally presented view (sheet, fullScreenCover, etc.) managed by this router's <code>sheetCoordinator</code>.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">close(animated:finishFlow:)</code></td>
      <td>
        <ul>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
          <li><b>finishFlow:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">false</code> (currently unused by the router itself, but might be relevant for coordinator logic)</li>
        </ul>
      </td>
      <td>Intelligently closes the top-most view: dismisses a sheet if one is presented by this router's <code>sheetCoordinator</code>, otherwise pops a view from this router's navigation stack.</td>
    </tr>
  </tbody>
</table>
<br>

#### Coordinator
The `Coordinator` is the brain for a specific navigation flow or feature. You subclass `Coordinator<YourRouteType>` to define navigation methods specific to that flow.

<br>
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Parameters</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code style="color: blue;">router</code></td>
      <td>N/A (Property)</td>
      <td>Instance of <code>Router<Route></code> specific to this coordinator. Use this for all navigation operations within this coordinator's flow (e.g., <code>router.navigate(toRoute:)</code>, <code>router.pop()</code>, <code>router.dismiss()</code>).</td>
    </tr>
    <tr>
      <td><code style="color: blue;">start(animated:)</code></td>
      <td>
        <ul>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>**Must be overridden by subclasses.** This is where you define the initial view or flow for the coordinator, typically by calling <code>await startFlow(route:animated:)</code>.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">startFlow(route:transitionStyle:animated:)</code></td>
      <td>
        <ul>
          <li><b>route:</b> <code>Route</code> (Your specific RouteType)</li>
          <li><b>transitionStyle:</b> <code>TransitionPresentationStyle?</code>, default: <code style="color: #ec6b6f;">nil</code> (uses route's default)</li>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Clears this coordinator's current navigation stack and any sheets it presented, then starts a new flow with the given route. This is essential for initializing or resetting the coordinator's view hierarchy.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">finishFlow(animated:)</code></td>
      <td>
        <ul>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Dismisses all views (pushed or presented) managed by *this* coordinator and removes *this* coordinator from its parent coordinator's children list. Effectively ends this coordinator's lifecycle and its associated UI.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">forcePresentation(presentationStyle:animated:mainCoordinator:)</code></td>
      <td>
        <ul>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code>, default: <code style="color: #ec6b6f;">nil</code> (uses presentation style of the coordinator's root view defined in its <code>start()</code> via <code>startFlow()</code>)</li>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
          <li><b>mainCoordinator:</b> <code>(any CoordinatorType)?</code>, default: <code style="color: #ec6b6f;">nil</code> (attempts to find the top-most coordinator in the app to present from)</li>
        </ul>
      </td>
      <td>Forcefully presents *this* coordinator, even if other coordinators or views are active. Useful for handling deep links or push notifications. It will call this coordinator's <code>start()</code> method.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">navigate(to:presentationStyle:animated:)</code></td>
      <td>
        <ul>
          <li><b>to:</b> <code>any CoordinatorType</code> (Another coordinator instance)</li>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code>, default: <code style="color: #ec6b6f;">nil</code> (uses presentation style of the target coordinator's root view, or can be overridden)</li>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Navigates from *this* coordinator to *another* coordinator. It adds the target coordinator as a child, sets its parent, and calls the target coordinator's <code>start()</code> method. The presentation style determines how the new coordinator's view is shown (e.g., pushed onto this coordinator's stack, or presented as a sheet by this coordinator).</td>
    </tr>
  </tbody>
</table>
<br>



##### `TabCoordinator` API

<br>
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Parameters / Type</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code style="color: blue;">router</code></td>
      <td><code>Router<DefaultRoute></code> (Property)</td>
      <td>The router for the <code>TabCoordinator</code> itself (e.g., for how it's presented or if it needs to present something over the tabs). Not for navigation within individual tabs.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">pages</code></td>
      <td><code>@Published var pages: [Page]</code> (Property)</td>
      <td>The array of <code>TabPage</code> enums that define the tabs. Modifying this will update the tab bar.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">currentPage</code></td>
      <td><code>@Published var currentPage: Page</code> (Property)</td>
      <td>Get or set the currently selected <code>TabPage</code>. Changing this programmatically will switch the active tab.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">setPages(_:currentPage:)</code></td>
      <td>
        <ul cellspacing="0" cellpadding="0">
          <li><b>_ values:</b> <code>[Page]</code></li>
          <li><b>currentPage:</b> <code>Page?</code> (optional new current page if the old one is removed)</li>
        </ul>
      </td>
      <td>Asynchronously updates the set of pages (tabs) dynamically. Child coordinators for new pages are initialized, and old ones are cleaned up.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">getCoordinatorSelected()</code></td>
      <td>Returns <code>any CoordinatorType</code> (Throws)</td>
      <td>Returns the child <code>CoordinatorType</code> instance that is currently active/selected based on <code>currentPage</code>. Throws <code>TabCoordinatorError.coordinatorSelected</code> if not found.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">getCoordinator(with:)</code></td>
      <td>
        <ul cellspacing="0" cellpadding="0">
          <li><b>position:</b> <code>Int</code></li>
        </ul>
        Returns <code>AnyCoordinatorType?</code>
      </td>
      <td>Returns the child <code>CoordinatorType</code> instance at the given numerical position (index) in the tabs.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">setBadge</code></td>
      <td><code>PassthroughSubject<(String?, Page), Never></code> (Property)</td>
      <td>A Combine subject to set or remove a badge on a tab. Send a tuple: <code>("badgeText", .yourTabPage)</code> to set, or <code>(nil, .yourTabPage)</code> to remove the badge. The <code>TabViewCoordinator</code> and example <code>CustomTabView</code> handle displaying these.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">viewContainer</code></td>
      <td><code>(TabCoordinator<Page>) -> Page.View</code> (Property)</td>
      <td>A closure that you provide during initialization. It returns the SwiftUI view for the tab bar interface itself (e.g., `TabViewCoordinator` or your `CustomTabView`).</td>
    </tr>
  </tbody>
</table>
<br>

## Advanced: Deep Linking with Push Notifications

`SUICoordinator`'s `forcePresentation` method is key for handling deep links, such as those from push notifications. This allows you to direct users to specific app sections.

### Simplified Deep Link Example

Assume:
- `AppRootCoordinator`: Your app's main coordinator.
- `MainTabCoordinator`: A `TabCoordinator` for your main tabs (e.g., using `AppTabPage.home`, `AppTabPage.settings`).
- `SettingsCoordinator`: A child coordinator for the `.settings` tab, with a route `.itemDetails(id: String)`.
- `AppTabPage`: Your enum for tab pages.
- You receive `targetTab: AppTabPage` and `itemId: String` from a push notification.

```swift
// In your App struct or AppDelegate, where you handle incoming notifications:
import SUICoordinator
import SwiftUI // For @MainActor

@MainActor
func handlePushNotificationDeepLink(
    targetTab: AppTabPage, // e.g., .settings
    itemId: String,        // e.g., "product123"
    rootCoordinator: AppRootCoordinator // Your app's main coordinator
) async {
    // 1. Instantiate the TabCoordinator you want to deep link into.
    //    Set its initialPage; it will be changed shortly if needed.
    let tabCoordinator = MainTabCoordinator(initialPage: .home)

    do {
        // 2. Force present the TabCoordinator over the current context.
        //    This calls tabCoordinator.start() and makes its view active.
        try await tabCoordinator.forcePresentation(
            presentationStyle: .fullScreenCover, // Or .sheet, as appropriate
            mainCoordinator: rootCoordinator
        )

        // 3. Change to the target tab if it's not the initial one.
        if tabCoordinator.currentPage != targetTab {
            tabCoordinator.currentPage = targetTab
            // A tiny delay can help ensure the tab switch completes UI-wise
            // before navigating within the new tab's coordinator.
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }

        // 4. Get the active coordinator for the target tab.
        guard let childCoordinator = try tabCoordinator.getCoordinatorSelected() else {
            print("Error: Could not get child coordinator for tab \(targetTab)")
            return
        }

        // 5. Navigate within the child coordinator.
        //    This example assumes SettingsCoordinator has a specific method for this.
        if let settingsCoordinator = childCoordinator as? SettingsCoordinator {
            await settingsCoordinator.navigateToItemDetails(id: itemId)
        } else {
            // Handle other tab types or log an error
            print("Deep link target coordinator is not SettingsCoordinator.")
        }

    } catch {
        print("Error during deep link force presentation: \(error)")
    }
}

// --- Hypothetical setup in your App struct ---
// @main
// struct YourApp: App {
//     var appRootCoordinator = AppRootCoordinator()
//
//     var body: some Scene {
//         WindowGroup {
//             appRootCoordinator.getView()
//                 .onReceive(yourPushNotificationPublisher) { notificationData in
//                     Task {
//                         // Parse notificationData to get targetTab and itemId
//                         let targetTab: AppTabPage = .settings // Example
//                         let itemId: String = "product123"   // Example
//
//                         await handlePushNotificationDeepLink(
//                             targetTab: targetTab,
//                             itemId: itemId,
//                             rootCoordinator: appRootCoordinator
//                         )
//                     }
//                 }
//         }
//     }
// }
```
**Key Steps:**
1.  **Instantiate Target Coordinator**: Create an instance of the coordinator you want to present (e.g., `MainTabCoordinator`).
2.  **`forcePresentation`**: Call this on the instantiated coordinator, passing your app's current root/main coordinator. This makes the target coordinator active.
3.  **Set State (if needed)**: For a `TabCoordinator`, update `currentPage` to the desired tab.
4.  **Get Child Coordinator**: Use `getCoordinatorSelected()` if navigating within a tab.
5.  **Navigate in Child**: Call relevant navigation methods on the child coordinator.

This approach ensures that the navigation hierarchy is correctly established before attempting to navigate to the final destination screen.
_____

## Contributing

Contributions to the SUICoordinator library are welcome! To contribute, simply fork this repository and make your changes in a new branch. When your changes are ready, submit a pull request to this repository for review.
