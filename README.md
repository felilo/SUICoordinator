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

_____

### Concept Glossary (🧭 quick definitions)

| Term | One-liner |
|------|-----------|
| **Route** | Enum case that maps directly to a SwiftUI `View` and knows how it should be presented. |
| **Coordinator** | Orchestrates a navigation flow. Owns a `Router`. |
| **Router** | Executes the navigation mechanics (push / sheet / dismiss) requested by its coordinator. |
| **TabCoordinator** | A coordinator that manages multiple child coordinators—one per tab. |
| **TransitionPresentationStyle** | Value describing *how* a view is shown (`.push`, `.sheet`, `.detents`, …). |

Having these terms in mind will make the code samples easier to digest.

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

*Want to run something immediately?* **Clone the example app** → [Examples folder](https://github.com/felilo/SUICoordinator/blob/main/Examples/SUICoordinatorExample/SUICoordinatorExample).
_____

## Basic Usage

### 1. Define Your Routes
Create an enum that conforms to `RouteType` to define your navigation paths and their associated views.

```swift
import SwiftUI
import SUICoordinator

enum HomeRoute: RouteType {
    case homeView(dependencies: DependenciesHomeView)
    case pushView(dependencies: DependenciesPushView)
    case sheetView(coordinator: HomeCoordinator)
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
            case .sheetView: .sheet
            default: .push
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
            case .homeView(let dependencies): HomeView(dependencies: .init(dependencies))
            case .pushView(let dependencies): PushView(dependencies: .init(dependencies))
            case .sheetView(let coordinator): SheetView(coordinator: coordinator)
        }
    }
}
```

For a deeper dive into route protocol, take a look at [RouteType](https://github.com/felilo/SUICoordinator?tab=readme-ov-file#routetype)

### 2. Create Your Coordinator
Subclass `Coordinator<YourRouteType>` and implement the mandatory `start()` method. This method defines the initial view or flow for the coordinator.

```swift
import SUICoordinator

class HomeCoordinator: Coordinator<HomeRoute> {
    
    override func start() async {
        // This is the first view the coordinator will show.
        // 'startFlow' clears any existing navigation stack and presents this route.
        let dependencies = HomeViewDependencies()
        await startFlow(route: .homeView(dependencies: dependencies))
    }
    
    // Example: Navigating to another view within this coordinator's flow
    func navigateToPushView() async {
        let dependencies = PushViewDependencies()
        await navigate(toRoute: .pushView(dependencies: dependencies))
    }
    
    // Example: Presenting a sheet
    func presentSheet() async {
        await navigate(toRoute: .sheetView(coordinator: self))
    }
    
    // Example: Navigating to another Coordinator (e.g., a TabCoordinator)
    func presentDefaultTabs() async {
        let coordinator = DefaultTabCoordinator() // Assuming this is your TabCoordinator
        await navigate(to: coordinator, presentationStyle: .sheet))
    }
    
    // Example: Override the default presentation style
    func presentSheet() async {
        await navigate(toRoute: .sheetView(coordinator: self), presentationStyle: .detents([.medium, .large]))
    }
    
    // 'finishFlow()' will dismiss/pop all views of this coordinator
    func endThisCoordinator() async {
        await finishFlow()
    }
}
```

### 3. Define Views 

```swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinator: HomeCoordinator
    
    var body: some View {
        List {
            Button("Push Example View") { Task { await coordinator.navigateToPushView() } }
            Button("Present Sheet Example") { Task { await coordinator.presentSheet() } }
            Button("Present Tab Coordinator") { Task { await coordinator.presentDefaultTabs() } }
        }
        .navigationTitle("Coordinator Actions")
    }
}
```

#### 3.1 Do you prefer to use ViewModels and Dependency Injection? 
Your SwiftUI views will typically be initialized with a ViewModel. The ViewModel can hold a reference to its coordinator to trigger navigation actions.

```swift
// ActionListViewModel.swift
import Foundation

class HomeViewModel: ObservableObject {
    let coordinator: HomeCoordinator 
    
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
        await coordinator.presentDefaultTabs()
    }
}

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
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
struct MyExampleApp: App {
    
    // Instantiate your main/root coordinator
    var rootCoordinator = HomeCoordinator() // Or your primary app coordinator
    
    var body: some Scene {
        WindowGroup { rootCoordinator.getView() }
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
            case .homeCoordinator: Image(systemName: "house.fill")
            case .settingsCoordinator: Image(systemName: "gearshape.fill")
        }
    }

    @ViewBuilder public var title: some View {
        switch page {
            case .homeCoordinator: Text("Home")
            case .settingsCoordinator: Text("Settings")
        }
    }
}

// Step 1.2: Define your TabPage enum
enum AppTabPage: TabPage, CaseIterable { // CaseIterable is useful for providing .allCases
    case homeCoordinator
    case settingsCoordinator

    // PageDataSource conformance
    var position: Int {
        switch self {
            case .homeCoordinator: return 0
            case .settingsCoordinator: return 1
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
            case .homeCoordinator: return HomeCoordinator() // Create and return a new instance
            case .settingsCoordinator: return SettingsCoordinator() // Create and return a new instance
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
// (See CustomTabView.swift and DefaultTabCoordinator.swift in the example project for a full implementation)
class DefaultTabCoordinator: TabCoordinator<AppTabPage> {
    init(initialPage: AppTabPage = .home) {
        super.init(
            pages: AppTabPage.allCases,
            currentPage: initialPage,
            viewContainer: { dataSource in
                // Provide your custom tab bar view.
                DefaultTabView(dataSource: dataSource)
            }
        )
    }
}
```

For a detailed example, you can take a look at the [DefaultTabView.swift](https://github.com/felilo/SUICoordinator/blob/main/Examples/SUICoordinatorExample/SUICoordinatorExample/Coordinators/TabCooridnators/DefaultTabCoordinator/DefaultTabView.swift) implementation.

#### 3. Using the `TabCoordinator`
Instantiate and start your `TabCoordinator` from a parent coordinator or as a root coordinator, just like any other coordinator.

```swift
// In a parent coordinator (e.g., your main AppRootCoordinator)
class HomeCoordinator: Coordinator<HomeRoute> {
    ...
    
    // Example: Navigating to another Coordinator (e.g., a TabCoordinator)
    func presentDefaultTabs() async {
        let tabCoordinator = DefaultTabCoordinator() // Assuming this is your TabCoordinator
        await navigate(to: tabCoordinator, presentationStyle: .detents(.medium))
    }
    
    ...
}
```

### Deep Linking or Push Notifications

`SUICoordinator` facilitates deep linking (e.g., from push notifications) by allowing you to programmatically navigate to specific parts of your application. The primary method for this is `forcePresentation(rootCoordinator:)` on a target coordinator. For tab-based applications, you'll combine this with `TabCoordinator` methods like `setCurrentPage(with:)` (or direct assignment to `currentPage`) and then use the child coordinator's `router` for further navigation.

#### General Strategy for Deep Linking:

1.  **Identify the Target:** Determine the ultimate destination:
    *   If it's within a `TabCoordinator`, identify the `TabCoordinator` itself, the target `TabPage`, and the specific `Route` within that tab's child coordinator.
    *   If it's a standalone flow, identify the `Coordinator` and its initial `Route`.
2.  **Instantiate Coordinators:** Create instances of the necessary coordinators. For a deep link into a tab, this usually means instantiating the relevant `TabCoordinator`.
3.  **Force Present the Entry Coordinator:** Call `yourTargetCoordinator.forcePresentation(presentationStyle: rootCoordinator:)`.
    *   `yourTargetCoordinator` is the coordinator that directly leads to the deep link's entry point (e.g., a `TabCoordinator` or a specific feature `Coordinator`).
    *   `rootCoordinator` should be your application's root/main coordinator to establish the correct presentation context. This step ensures the target coordinator's view hierarchy becomes active, potentially dismissing or covering other views.
4.  **Navigate to the Specific Tab (if applicable):** If `yourTargetCoordinator` is a `TabCoordinator`:
    *   Set its `currentPage` to the desired `TabPage`. For example: `yourTabCoordinator.currentPage = .settingsTab`.
    *   A brief `Task.sleep` (e.g., `try? await Task.sleep(nanoseconds: 100_000_000)` for 0.1s) after setting `currentPage` can sometimes help ensure UI updates complete before further navigation.
5.  **Navigate Within the Active Coordinator:**
    *   If it's a `TabCoordinator`, get the active child coordinator using `try await yourTabCoordinator.getCoordinatorSelected()`.
    *   Cast this child coordinator to its concrete type (e.g., `SettingsCoordinator`).
    *   Use this coordinator's `router` to navigate to the final `Route` (e.g., `await settingsCoordinator.router.navigate(toRoute: SettingsRoute.itemDetails(id: "itemID123"))`).


```swift
@main
struct MyExampleApp: App {
    
    /// The main coordinator for the application, responsible for managing the primary tab-based navigation.
    /// It's an instance of `DefaultTabCoordinator` which uses the standard SwiftUI `TabView`.
    var rootCoordinator = DefaultTabCoordinator()
    
    /// The body of the app, defining the main scene.
    /// It sets up a `WindowGroup` containing the view provided by the `rootCoordinator`.
    /// - It includes `onReceive` for handling custom notifications that might trigger deep links.
    /// - It includes `onOpenURL` for handling URL-based deep links.
    /// - An `onAppear` modifier simulates an automatic deep link handling scenario after a 3-second delay
    ///   on application launch, demonstrating programmatic navigation.
    var body: some Scene {
        WindowGroup {
                rootCoordinator.getView()
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.PushNotification)) { object in
                    // Assumes `incomingURL` is accessible or passed via notification's object/userInfo
                    // For demonstration, let's assume `object.object` contains the URL string
                    guard let urlString = object.object as? String,
                          let path = DeepLinkPath(rawValue: urlString) else { return }
                    Task {
                        await try? handlePushNotificationDeepLink(path: path, rootCoordinator: rootCoordinator)
                    }
                }
                .onOpenURL { incomingURL in
                    guard let host = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true)?.host,
                          let path = DeepLinkPath(rawValue: host)
                    else { return }
                    
                    Task { @MainActor in
                        try? await handlePushNotificationDeepLink(path: path, rootCoordinator: rootCoordinator)
                    }
                }
        }
    }
    
    /// Defines possible deep link paths for the application.
    /// These raw string values would typically match URL schemes or notification payloads.
    /// - `home`: Represents a path to a home-like view, potentially within a tab, to present a detents sheet.
    /// - `tabCoordinator`: Represents a path to present a `DefaultTabCoordinator` modally.
    enum DeepLinkPath: String {
        case home = "home" // Example: "yourapp://home" or a notification payload "home"
        case tabCoordinator = "tabs-coordinator" // Example: "yourapp://tabs/coordinator"
    }
    
    
    /// Handles deep link navigation based on the provided path.
    ///
    /// This function demonstrates how to programmatically navigate to specific parts of the app
    /// by interacting with the coordinator hierarchy. It's designed to be called from
    /// `onOpenURL`, `onReceive` (for notifications), or other app events.
    ///
    /// - Parameters:
    ///   - path: The `DeepLinkPath` indicating the destination within the app.
    ///   - rootCoordinator: The root `AnyCoordinatorType` instance of the application (e.g., `rootCoordinator`),
    ///     used as a starting point to traverse and manipulate the coordinator tree.
    @MainActor func handlePushNotificationDeepLink(
        path: DeepLinkPath,
        rootCoordinator: AnyCoordinatorType
    ) async throws {
        switch path {
        case .tabCoordinator:
            /// Deep-link intent:
            /// Present the detents sheet that belongs to the `HomeCoordinator`
            /// ‑-but only if that coordinator is the one *currently visible* to the user.
            ///
            /// How it works:
            /// `getCoordinatorPresented()` walks the hierarchy to return
            ///    • the “top-most” coordinator of any modal stack, **or**
            ///    • the coordinator that controls the *selected* tab when inside a tab container.
            ///    In short, it yields the coordinator the user is actively interacting with.
            /// When the cast succeeds we call `presentSheet()` which
            ///    brings up the sheet configured inside `HomeCoordinator`.
            
            if let coordinator = try rootCoordinator.getCoordinatorPresented() as? HomeCoordinator {
                await coordinator.presentSheet()
            } else {
                let homeCoordinator = HomeCoordinator()
                try await homeCoordinator.forcePresentation(rootCoordinator: rootCoordinator)
                await homeCoordinator.presentSheet()
            }
        case .home:
            // This case demonstrates presenting a different Coordinator modally (HomeCoordinator in this example).
            // It creates a new `HomeCoordinator` instance and uses `forcePresentation`
            // to display it as a sheet over the current context, managed by the `rootCoordinator`.
            let coordinator = HomeCoordinator()
            try await coordinator.forcePresentation(
                presentationStyle: .sheet,
                rootCoordinator: rootCoordinator
            )
        }
    }
}
```
<br>

### Example project

For a comprehensive understanding and more advanced use cases, including `TabCoordinator` examples (both default SwiftUI `TabView` and custom tab views), please explore the example project located in the [Examples folder](https://github.com/felilo/SUICoordinator/tree/main/Examples/SUICoordinatorExample).


![coordinator-ezgif com-resize](https://github.com/user-attachments/assets/98a90863-3e35-48b3-9a9f-cf8757d5e0d6)


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
    *   A computed property, annotated with `@ViewBuilder`
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
                return .detents([.medium, .large]) // Help sheet with detents
            case .customTransitionView:
                return .custom( // Example of a custom transition
                    transition: .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)),
                    animation: .easeInOut(duration: 0.5),
                    fullScreen: true
                )
        }
    }

    // 2. view
    @ViewBuilder
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

You can also use `DefaultRoute` for generic views if you don't need a specific enum for routes, as demonstrated in the `TabFlowCoordinator` [example](https://github.com/felilo/SUICoordinator/blob/main/Examples/SUICoordinatorExample/SUICoordinatorExample/Coordinators/NavigationHubCoordinator/NavigationHubCoordinator.swift).
<br>

### API
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
      <td><code style="color: blue;">dismiss(animated:)</code></td>
      <td>
        <ul>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Dismisses the top-most modally presented view (sheet, fullScreenCover, etc.) managed by this router's <code>sheetCoordinator</code>.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">close(animated:)</code></td>
      <td>
        <ul>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Closes the current screen context: if presented modally it dismisses, otherwise it pops the navigation stack.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">restart(animated:)</code></td>
      <td>
        <ul>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Clears the router’s navigation state — all stacks and sheet presentations are removed and the router returns to its initial state (<code>mainView</code> remains intact).</td>
    </tr>
    <tr>
      <td><code style="color: blue;">syncItems()</code></td>
      <td>N/A</td>
      <td>Synchronises the published <code>items</code> array with the internal navigation-stack state. Useful when UI state becomes out-of-sync after complex mutations.</td>
    </tr>
  </tbody>
</table>
<br>

##### Coordinator
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
      <td><code style="color: blue;">forcePresentation(presentationStyle:animated:rootCoordinator:)</code></td>
      <td>
        <ul>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code>, default: <code style="color: #ec6b6f;">nil</code> (uses presentation style of the coordinator's root view defined in its <code>start()</code> via <code>startFlow()</code>)</li>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
          <li><b>rootCoordinator:</b> <code>(any CoordinatorType)?</code>, default: <code style="color: #ec6b6f;">nil</code> (attempts to find the top-most coordinator in the app to present from)</li>
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
    <tr>
      <td><code style="color: blue;">navigate(toRoute:presentationStyle:animated:)</code></td>
      <td>
        <ul>
          <li><b>toRoute:</b> <code>Route</code> (Your specific RouteType)</li>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code>, default: <code style="color: #ec6b6f;">nil</code> (uses presentation style of the target coordinator's root view, or can be overridden)</li>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Simple convenience wrapper for the router’s <code>navigate(toRoute:presentationStyle:animated:)</code> method.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">restart(animated:)</code></td>
      <td>
        <ul>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Resets the coordinator's navigation state by calling <code>router.restart()</code>. This clears all navigation stacks and modal presentations managed by this coordinator. All navigation history will be lost, modal presentations dismissed, and the coordinator returns to its initial state as if <code>start()</code> was just called (depending on how <code>start()</code> and <code>startFlow()</code> are implemented). Useful for logout scenarios or major state changes.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">close(animated:)</code></td>
      <td>
        <ul>
          <li><b>animated:</b> <code>Bool</code>, default: <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Forwards to the router’s <code>close(animated:)</code> method.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">getCoordinatorPresented(customRootCoordinator:)</code></td>
      <td>
        <ul>
          <li><b>customRootCoordinator:</b> <code>AnyCoordinatorType?</code>, default: <code style="color: #ec6b6f;">nil</code></li>
        </ul>
      </td>
      <td>Returns the coordinator currently visible to the user. It searches for the top-most coordinator starting from <code>customRootCoordinator</code> (or <code>self</code> when <code>nil</code>). If that coordinator is inside a <code>TabCoordinatable</code>, the selected tab’s coordinator is returned; otherwise the top coordinator itself is returned.</td>
    </tr>
  </tbody>
</table>
<br>

##### TabCoordinator

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
          <li><b>page:</b> <code>TabPage</code></li>
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
_____

## Contributing

Contributions to the SUICoordinator library are welcome! To contribute, simply fork this repository and make your changes in a new branch. When your changes are ready, submit a pull request to this repository for review.
