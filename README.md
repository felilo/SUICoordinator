# SUICoordinator

A SwiftUI coordinator pattern library that provides clean navigation management and tab-based coordination for iOS applications. SUICoordinator separates navigation logic from view presentation, making your SwiftUI apps more maintainable and scalable.

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![iOS 16.0+](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/Framework-SwiftUI-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

_____

## Key Features

- **Pure SwiftUI**: No UIKit dependencies — built entirely with SwiftUI
- **Coordinator Pattern**: Clean separation of navigation logic from views
- **Dual iOS Support**: `SUICoordinator` (iOS 17+, `@Observable`) and `SUICoordinator16` (iOS 16+, `ObservableObject`) — same API, pick the right target for your deployment
- **Flexible Presentations**: Push, sheet, fullscreen, detents, and custom transitions
- **Tab Coordination**: Advanced tab-based navigation with `TabCoordinator`, custom views, and badges
- **Deep Linking**: Force presentation capabilities for push notifications and external triggers
- **Async Navigation**: Full async/await support for smooth navigation flows

_____

## Targets

SUICoordinator ships two importable products. Pick the one that matches your deployment target — both expose the same public API:

| Product | Minimum iOS | How observation works | When to use |
|---------|-------------|-----------------------|-------------|
| `SUICoordinator` | **17+** | `@Observable` macro | New projects or apps that already require iOS 17+ |
| `SUICoordinator16` | **16+** | `ObservableObject` + Combine | Apps that must support iOS 16 |

_____

## Installation

### Swift Package Manager

1. Open Xcode and your project
2. Go to `File` → `Add Package Dependencies...`
3. Enter the repository URL: `https://github.com/felilo/SUICoordinator`
4. Select the package product that matches your deployment target (see [Targets](#targets) above)

> A single `import SUICoordinator` (or `import SUICoordinator16`) is all you need — all public types are available immediately.

_____

## Basic Usage

### 1. Define Your Routes

Create an enum that conforms to `RouteType`. Each case maps to a SwiftUI view and declares how it should be presented.

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
    var body: some View {
        switch self {
            case .homeView(let dependencies): HomeView(dependencies: .init(dependencies))
            case .pushView(let dependencies): PushView(dependencies: .init(dependencies))
            case .sheetView(let coordinator): SheetView(coordinator: coordinator)
        }
    }
}
```

### 2. Create Your Coordinator

Subclass `Coordinator<YourRouteType>` and implement `start()` to define the initial view of the flow.

```swift
import SUICoordinator

class HomeCoordinator: Coordinator<HomeRoute> {

    override func start() async {
        let dependencies = HomeViewDependencies()
        await startFlow(route: .homeView(dependencies: dependencies))
    }

    func navigateToPushView() async {
        let dependencies = PushViewDependencies()
        await navigate(toRoute: .pushView(dependencies: dependencies))
    }

    func presentSheet() async {
        await navigate(toRoute: .sheetView(coordinator: self))
    }

    // Override the default presentation style for a route
    func presentSheetAsDetents() async {
        await navigate(toRoute: .sheetView(coordinator: self), presentationStyle: .detents([.medium, .large]))
    }

    // Navigate to another coordinator
    func presentDefaultTabs() async {
        let coordinator = DefaultTabCoordinator()
        await navigate(to: coordinator, presentationStyle: .sheet)
    }

    func endThisCoordinator() async {
        await finishFlow()
    }
}
```

### 3. Define Views

How a view receives its coordinator depends on which target you imported.

**iOS 17+ (`SUICoordinator`) — `@Observable`:**
```swift
import SwiftUI
import SUICoordinator

struct HomeView: View {
    @Environment(HomeCoordinator.self) var coordinator

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

**iOS 16+ (`SUICoordinator16`) — `ObservableObject`:**
```swift
import SwiftUI
import SUICoordinator16

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

### 4. Setup in Your App

Instantiate your root coordinator and use its `getView()` method.

```swift
import SwiftUI
import SUICoordinator

@main
struct MyExampleApp: App {

    var rootCoordinator = HomeCoordinator()

    var body: some Scene {
        WindowGroup { rootCoordinator.getView() }
    }
}
```

_____

## Example Project

Explore working implementations of all features — push, sheet, fullscreen, detents, custom transitions, tab coordinators (default and custom), and deep linking.

![coordinator-ezgif com-resize](https://github.com/user-attachments/assets/98a90863-3e35-48b3-9a9f-cf8757d5e0d6)

[Examples folder →](https://github.com/felilo/SUICoordinator/tree/main/Examples/SUICoordinatorExample)

_____

## Tab Navigation

`TabCoordinator<Page: TabPage>` manages a collection of child coordinators, one per tab.

### 1. Define Your Tab Pages

Create an enum conforming to `TabPage` with three requirements:
- `position: Int` — display order of the tab (0-indexed)
- `dataSource` — a value providing the tab's visual elements (icon, title, etc.)
- `coordinator() -> any CoordinatorType` — the coordinator that manages this tab's flow

```swift
import SwiftUI
import SUICoordinator

struct AppTabPageDataSource {
    let page: AppTabPage

    @ViewBuilder var icon: some View {
        switch page {
            case .home: Image(systemName: "house.fill")
            case .settings: Image(systemName: "gearshape.fill")
        }
    }

    @ViewBuilder var title: some View {
        switch page {
            case .home: Text("Home")
            case .settings: Text("Settings")
        }
    }
}

enum AppTabPage: TabPage, CaseIterable {
    case home
    case settings

    var position: Int {
        switch self {
            case .home: return 0
            case .settings: return 1
        }
    }

    var dataSource: AppTabPageDataSource {
        AppTabPageDataSource(page: self)
    }

    func coordinator() -> any CoordinatorType {
        switch self {
            case .home: return HomeCoordinator()
            case .settings: return SettingsCoordinator()
        }
    }
}
```

### 2. Create Your TabCoordinator

```swift
import SUICoordinator

class DefaultTabCoordinator: TabCoordinator<AppTabPage> {
    init(initialPage: AppTabPage = .home) {
        super.init(
            pages: AppTabPage.allCases,
            currentPage: initialPage,
            viewContainer: { dataSource in
                DefaultTabView(dataSource: dataSource)
            }
        )
    }
}
```

For a detailed example, see [DefaultTabView.swift](https://github.com/felilo/SUICoordinator/blob/main/Examples/SUICoordinatorExample/SUICoordinatorExample/Coordinators/TabCooridnators/DefaultTabCoordinator/DefaultTabView.swift).

### 3. Present the TabCoordinator

```swift
func presentDefaultTabs() async {
    let tabCoordinator = DefaultTabCoordinator()
    await navigate(to: tabCoordinator, presentationStyle: .sheet)
}
```

_____

## Deep Linking

Navigate to a specific part of the app from a push notification or a universal link using `forcePresentation(rootCoordinator:)`.

**General strategy:**
1. Identify the destination coordinator
2. Call `forcePresentation(presentationStyle:rootCoordinator:)` on it
3. For tab-based apps, set `currentPage` to the target tab, then navigate within the selected child coordinator

```swift
@main
struct MyExampleApp: App {

    var rootCoordinator = DefaultTabCoordinator()

    var body: some Scene {
        WindowGroup {
            rootCoordinator.getView()
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name.PushNotification)) { object in
                    guard let urlString = object.object as? String,
                          let path = DeepLinkPath(rawValue: urlString) else { return }
                    Task { try? await handleDeepLink(path: path) }
                }
                .onOpenURL { incomingURL in
                    guard let host = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true)?.host,
                          let path = DeepLinkPath(rawValue: host) else { return }
                    Task { @MainActor in try? await handleDeepLink(path: path) }
                }
        }
    }

    enum DeepLinkPath: String {
        case home = "home"
        case tabCoordinator = "tabs-coordinator"
    }

    @MainActor func handleDeepLink(path: DeepLinkPath) async throws {
        switch path {
        case .tabCoordinator:
            if let coordinator = try rootCoordinator.getCoordinatorPresented() as? HomeCoordinator {
                await coordinator.presentSheet()
            } else {
                let homeCoordinator = HomeCoordinator()
                try await homeCoordinator.forcePresentation(rootCoordinator: rootCoordinator)
                await homeCoordinator.presentSheet()
            }
        case .home:
            let coordinator = HomeCoordinator()
            try await coordinator.forcePresentation(
                presentationStyle: .sheet,
                rootCoordinator: rootCoordinator
            )
        }
    }
}
```

_____

## API Reference

### RouteType

Every route enum must conform to `RouteType`. Two requirements:

1. **`presentationStyle: TransitionPresentationStyle`** — how the view is shown:
    - `.push` — navigation stack
    - `.sheet` — standard modal sheet
    - `.fullScreenCover` — modal covering the entire screen
    - `.detents(Set<PresentationDetent>)` — sheet that rests at specific heights (e.g., `.detents([.medium, .large])`)
    - `.custom(transition: AnyTransition, animation: Animation?, fullScreen: Bool)` — custom SwiftUI transition

2. **`var body: some View`** — the SwiftUI view for the route case

```swift
import SwiftUI
import SUICoordinator

enum AppRoute: RouteType {
    case login
    case dashboard(userId: String)
    case helpSheet
    case customTransitionView

    var presentationStyle: TransitionPresentationStyle {
        switch self {
            case .login: return .fullScreenCover
            case .dashboard: return .push
            case .helpSheet: return .detents([.medium, .large])
            case .customTransitionView:
                return .custom(
                    transition: .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)),
                    animation: .easeInOut(duration: 0.5),
                    fullScreen: true
                )
        }
    }

    @ViewBuilder
    var body: some View {
        switch self {
            case .login: LoginView()
            case .dashboard(let userId): DashboardView(userId: userId)
            case .helpSheet: HelpView()
            case .customTransitionView: MyCustomAnimatedView()
        }
    }
}
```

> You can also use `DefaultRoute` for generic views when you don't need a typed route enum — as demonstrated in the [NavigationHubCoordinator example](https://github.com/felilo/SUICoordinator/blob/main/Examples/SUICoordinatorExample/SUICoordinatorExample/Coordinators/NavigationHubCoordinator/NavigationHubCoordinator.swift).

<br>

### Router

The `Router` (available as `coordinator.router`) manages the navigation stack and modal presentations for a single coordinator.

<br>
<table>
  <thead>
    <tr>
      <th>Method</th>
      <th>Parameters</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>navigate(toRoute:presentationStyle:animated:)</code></td>
      <td>
        <ul>
          <li><b>toRoute:</b> <code>Route</code></li>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code> — default: <code>nil</code> (uses route's default)</li>
          <li><b>animated:</b> <code>Bool</code> — default: <code>true</code></li>
        </ul>
      </td>
      <td>Navigates to the given route. <code>.push</code> pushes onto the navigation stack; everything else presents modally.</td>
    </tr>
    <tr>
      <td><code>present(_:presentationStyle:animated:)</code></td>
      <td>
        <ul>
          <li><b>_ view:</b> <code>Route</code></li>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code> — default: <code>.sheet</code></li>
          <li><b>animated:</b> <code>Bool</code> — default: <code>true</code></li>
        </ul>
      </td>
      <td>Presents a view modally. If the style is <code>.push</code>, delegates to <code>navigate(toRoute:)</code>.</td>
    </tr>
    <tr>
      <td><code>pop(animated:)</code></td>
      <td><b>animated:</b> <code>Bool</code> — default: <code>true</code></td>
      <td>Pops the top view from the navigation stack.</td>
    </tr>
    <tr>
      <td><code>popToRoot(animated:)</code></td>
      <td><b>animated:</b> <code>Bool</code> — default: <code>true</code></td>
      <td>Pops all views except the root from the navigation stack.</td>
    </tr>
    <tr>
      <td><code>dismiss(animated:)</code></td>
      <td><b>animated:</b> <code>Bool</code> — default: <code>true</code></td>
      <td>Dismisses the top-most modally presented view.</td>
    </tr>
    <tr>
      <td><code>close(animated:)</code></td>
      <td><b>animated:</b> <code>Bool</code> — default: <code>true</code></td>
      <td>Dismisses if presented modally; pops if pushed onto a navigation stack.</td>
    </tr>
    <tr>
      <td><code>restart(animated:)</code></td>
      <td><b>animated:</b> <code>Bool</code> — default: <code>true</code></td>
      <td>Clears all stacks and sheet presentations, returning the router to its initial state.</td>
    </tr>
    <tr>
      <td><code>syncItems()</code></td>
      <td>N/A</td>
      <td>Synchronises the published <code>items</code> array with internal navigation-stack state. Useful after complex mutations.</td>
    </tr>
  </tbody>
</table>
<br>

### Coordinator

<br>
<table>
  <thead>
    <tr>
      <th>Method / Property</th>
      <th>Parameters</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>router</code></td>
      <td>Property — <code>Router&lt;Route&gt;</code></td>
      <td>The router for this coordinator. Use it for all navigation within this coordinator's flow.</td>
    </tr>
    <tr>
      <td><code>start(animated:)</code></td>
      <td><b>animated:</b> <code>Bool</code> — default: <code>true</code></td>
      <td>Must be overridden. Define the initial view or flow here, typically via <code>await startFlow(route:)</code>.</td>
    </tr>
    <tr>
      <td><code>startFlow(route:transitionStyle:animated:)</code></td>
      <td>
        <ul>
          <li><b>route:</b> <code>Route</code></li>
          <li><b>transitionStyle:</b> <code>TransitionPresentationStyle?</code> — default: <code>nil</code></li>
          <li><b>animated:</b> <code>Bool</code> — default: <code>true</code></li>
        </ul>
      </td>
      <td>Clears the current navigation stack and starts a new flow with the given route.</td>
    </tr>
    <tr>
      <td><code>finishFlow(animated:)</code></td>
      <td><b>animated:</b> <code>Bool</code> — default: <code>true</code></td>
      <td>Dismisses all views managed by this coordinator and removes it from its parent's children list.</td>
    </tr>
    <tr>
      <td><code>navigate(toRoute:presentationStyle:animated:)</code></td>
      <td>
        <ul>
          <li><b>toRoute:</b> <code>Route</code></li>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code> — default: <code>nil</code></li>
          <li><b>animated:</b> <code>Bool</code> — default: <code>true</code></li>
        </ul>
      </td>
      <td>Convenience wrapper for <code>router.navigate(toRoute:presentationStyle:animated:)</code>.</td>
    </tr>
    <tr>
      <td><code>navigate(to:presentationStyle:animated:)</code></td>
      <td>
        <ul>
          <li><b>to:</b> <code>any CoordinatorType</code></li>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code> — default: <code>nil</code></li>
          <li><b>animated:</b> <code>Bool</code> — default: <code>true</code></li>
        </ul>
      </td>
      <td>Navigates to another coordinator. Adds it as a child, sets its parent, and calls its <code>start()</code>.</td>
    </tr>
    <tr>
      <td><code>forcePresentation(presentationStyle:animated:rootCoordinator:)</code></td>
      <td>
        <ul>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code> — default: <code>nil</code></li>
          <li><b>animated:</b> <code>Bool</code> — default: <code>true</code></li>
          <li><b>rootCoordinator:</b> <code>(any CoordinatorType)?</code> — default: <code>nil</code></li>
        </ul>
      </td>
      <td>Forcefully presents this coordinator from the top of the hierarchy. Used for deep links and push notifications.</td>
    </tr>
    <tr>
      <td><code>restart(animated:)</code></td>
      <td><b>animated:</b> <code>Bool</code> — default: <code>true</code></td>
      <td>Resets this coordinator's navigation state by calling <code>router.restart()</code>.</td>
    </tr>
    <tr>
      <td><code>close(animated:)</code></td>
      <td><b>animated:</b> <code>Bool</code> — default: <code>true</code></td>
      <td>Forwards to <code>router.close(animated:)</code>.</td>
    </tr>
    <tr>
      <td><code>getCoordinatorPresented(customRootCoordinator:)</code></td>
      <td><b>customRootCoordinator:</b> <code>AnyCoordinatorType?</code> — default: <code>nil</code></td>
      <td>Returns the coordinator currently visible to the user. Walks the hierarchy from <code>customRootCoordinator</code> (or <code>self</code>) to the top; follows the active tab inside a <code>TabCoordinator</code>.</td>
    </tr>
  </tbody>
</table>
<br>

### TabCoordinator

<br>
<table>
  <thead>
    <tr>
      <th>Method / Property</th>
      <th>Parameters / Type</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>router</code></td>
      <td>Property — <code>Router&lt;DefaultRoute&gt;</code></td>
      <td>The router for the <code>TabCoordinator</code> itself — not for navigation within individual tabs.</td>
    </tr>
    <tr>
      <td><code>pages</code></td>
      <td>Property — <code>[Page]</code><br><em>iOS 16: <code>@Published</code></em></td>
      <td>The array of <code>TabPage</code> enum cases defining the tabs.</td>
    </tr>
    <tr>
      <td><code>currentPage</code></td>
      <td>Property — <code>Page</code><br><em>iOS 16: <code>@Published</code></em></td>
      <td>Get or set the currently selected tab. Changing this programmatically switches the active tab.</td>
    </tr>
    <tr>
      <td><code>setPages(_:currentPage:)</code></td>
      <td>
        <ul>
          <li><b>_ values:</b> <code>[Page]</code></li>
          <li><b>currentPage:</b> <code>Page?</code></li>
        </ul>
      </td>
      <td>Dynamically updates the tab set. Initializes coordinators for new pages and cleans up removed ones.</td>
    </tr>
    <tr>
      <td><code>getCoordinatorSelected()</code></td>
      <td>Returns <code>any CoordinatorType</code> (throws)</td>
      <td>Returns the child coordinator for the currently selected tab. Throws <code>TabCoordinatorError.coordinatorSelected</code> if not found.</td>
    </tr>
    <tr>
      <td><code>getCoordinator(with:)</code></td>
      <td><b>page:</b> <code>TabPage</code><br>Returns <code>AnyCoordinatorType?</code></td>
      <td>Returns the child coordinator for the given <code>TabPage</code>, or <code>nil</code> if not found.</td>
    </tr>
    <tr>
      <td><code>setBadge</code></td>
      <td>Property — <code>PassthroughSubject&lt;(String?, Page), Never&gt;</code></td>
      <td>Send <code>("3", .yourTab)</code> to set a badge, or <code>(nil, .yourTab)</code> to remove it.</td>
    </tr>
  </tbody>
</table>
<br>

_____

## Contributing

Contributions are welcome! Fork the repository, make your changes in a new branch, and open a pull request for review.
