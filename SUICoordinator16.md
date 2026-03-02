# SUICoordinator16 — iOS 16 Support

`SUICoordinator16` is the iOS 16-compatible target of SUICoordinator. It exposes the same public API as `SUICoordinator` but uses `ObservableObject` + Combine instead of `@Observable`.

---

## When to Use

Use `SUICoordinator16` when your app must support **iOS 16**. If your deployment target is iOS 17+, prefer `SUICoordinator`.

---

## Installation

Add `SUICoordinator16` (instead of `SUICoordinator`) when configuring the package in Xcode:

1. Open Xcode and your project
2. Go to `File` → `Add Package Dependencies...`
3. Enter the repository URL: `https://github.com/felilo/SUICoordinator`
4. Select **`SUICoordinator16`** as the package product

---

## Basic Usage

### 1. Define Your Routes

Routes are identical to `SUICoordinator` — `RouteType` is shared:

```swift
import SwiftUI
import SUICoordinator16

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

Subclass `Coordinator<Route>`:

```swift
import SUICoordinator16

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

    func endThisCoordinator() async {
        await finishFlow()
    }
}
```

### 3. Define Views

Use `@EnvironmentObject` to access the coordinator:

```swift
import SwiftUI
import SUICoordinator16

struct HomeView: View {
    @EnvironmentObject var coordinator: HomeCoordinator

    var body: some View {
        List {
            Button("Push Example View") { Task { await coordinator.navigateToPushView() } }
            Button("Present Sheet Example") { Task { await coordinator.presentSheet() } }
        }
        .navigationTitle("Coordinator Actions")
    }
}
```

### 4. Setup in Your App

```swift
import SwiftUI
import SUICoordinator16

@main
struct MyExampleApp: App {

    var rootCoordinator = HomeCoordinator()

    var body: some Scene {
        WindowGroup { rootCoordinator.getView() }
    }
}
```

---

## Key Differences from `SUICoordinator`

| | `SUICoordinator` (iOS 17+) | `SUICoordinator16` (iOS 16+) |
|---|---|---|
| Observation | `@Observable` | `ObservableObject` + `@Published` |
| View injection | `@Environment(CoordinatorType.self)` | `@EnvironmentObject var coordinator: CoordinatorType` |
| Coordinator macro | `@Coordinator` (available) | Not available |

All navigation methods (`navigate`, `startFlow`, `finishFlow`, `forcePresentation`, `close`, `restart`, etc.) are identical between both targets.
