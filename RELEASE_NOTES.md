# Release Notes — v1.1.2

## Bug Fixes

### Memory leak in `RouterView` — `Router` no longer owned by the view
`RouterView` previously held its own `@State var viewModel: Router<...>`, creating an independent router instance that was separate from the coordinator's router. This caused the router to be retained by the view even after the coordinator finished, leading to a memory leak. `RouterView` now reads the router directly from its coordinator, ensuring the router's lifetime is tied to the coordinator.

### Coordinator environment not propagated through sheet presentations
The coordinator was not available via `@Environment(\.coordinator)` (or `@EnvironmentObject` on iOS 16) inside views presented as sheet, fullScreenCover, or detents. `.environment(\.coordinator, coordinator)` is now applied after the `sheetCoordinator` modifier in `RouterView`, so all presented views receive the coordinator correctly.

### `SheetCoordinator.clean()` left observable `items` out of sync
After `clean()` cleared the internal `ItemManager`, it did not call `updateItems()`, leaving the observable `items` array with stale entries. Views and tests observing `sheetCoordinator.items` would see incorrect counts. `clean()` now calls `updateItems()` after clearing state.

### `@Coordinator` macro applied `@ObservationTracked` to `@ObservationIgnored` vars
The `MemberAttributeMacro` role of `@Coordinator` unconditionally applied `@ObservationTracked` to all stored `var` properties, including those already annotated with `@ObservationIgnored`. This caused a compiler error when both attributes were present. The macro now skips `@ObservationTracked` when `@ObservationIgnored` is already on the property.

## Improvements

### Shared coordinator environment key
A shared `\.coordinator` environment key (`EnvironmentValues.coordinator: (any CoordinatorType)?`) has been added to both `SUICoordinator` and `SUICoordinator16`. Views can now access their coordinator without importing a specific coordinator type:

```swift
// iOS 17
@Environment(\.coordinator) private var coordinator

// iOS 16
@Environment(\.coordinator) private var coordinator
```

### `Router.setView(with:)` added to `RouterType`
`setView(with:)` is now part of the `RouterType` protocol, making it accessible anywhere a `RouterType` is used.

---

# Release Notes — v1.1.1

## Improvements

### `@Coordinator` macro — custom `init` now supported
Previously, coordinators using the `@Coordinator` macro could not define a custom `init` with parameters because the macro always generated a fixed `@MainActor public init()` that owned the `router` assignment. `Router.init()` is now `nonisolated` and `router` is initialized inline as a stored-property default, freeing the generated `init` from `@MainActor` and allowing user-written initializers to coexist without any actor annotation.

```swift
// Before — custom init was not possible; only the macro-generated init() could be used
@Coordinator(HomeRoute.self)
class HomeCoordinator {
    // ❌ could not add custom init with parameters
}

// After — custom init works with no boilerplate
@Coordinator(HomeRoute.self)
class HomeCoordinator {
    @ObservationIgnored private let animated: Bool

    init(animated: Bool = true) {
        self.animated = animated
    }
}
```

### `Router.init()` is now `nonisolated`
`Router.init()` no longer requires a `@MainActor` context, making it safe to call as a stored-property inline default and from `nonisolated` init sites.

---

# Release Notes — v1.0.1

## New Features

### `SUICoordinator16` — iOS 16 Support
A new `SUICoordinator16` target mirrors the full `SUICoordinator` API using `ObservableObject` + Combine, allowing the same coordinator pattern on iOS 16+ deployments.

- Views inject coordinators via `.environmentObject()` / `@EnvironmentObject`
- All coordinator, router, sheet, and tab types use `@Published` for reactive properties
- Identical public API surface to `SUICoordinator` — switch targets, not code patterns

### `SUICoordinatorCore` — Shared Foundation
A new `SUICoordinatorCore` target extracts platform-agnostic types (routes, sheet items, actors, view helpers) into a dependency-free module shared by both platform layers. Both `SUICoordinator` and `SUICoordinator16` re-export it automatically — no additional import needed.

### `@Coordinator` Macro (iOS 17+)
A new `@Coordinator(Route.self)` Swift macro eliminates boilerplate for coordinator classes. Instead of subclassing `Coordinator<Route>`, annotate a plain class:

```swift
@Coordinator(HomeRoute.self)
class HomeCoordinator {
    func start() async {
        await startFlow(route: .home)
    }
}
```

The macro generates `router`, `uuid`, `parent`, `children`, `tagId`, and `init()` automatically, and conforms the class to `CoordinatorType`.

### `getCoordinatorPresented()`
New function on `CoordinatorType` that traverses the active coordinator hierarchy and returns the currently visible coordinator. Useful for deep linking and analytics.

```swift
let active = try rootCoordinator.getCoordinatorPresented()
```

### Navigation Helper `navigate(toRoute:)`
New convenience method on `CoordinatorType` that wraps the route-based navigation call, reducing the amount of code needed in coordinator subclasses.

---

## Improvements

- **`@Observable` migration** — `SUICoordinator` (iOS 17+) now uses the `@Observable` macro throughout. `CoordinatorView` uses `@State`, `RouterView` uses `.environment()`, and `SheetCoordinatorView` uses `@Bindable`. This removes the Combine dependency from the iOS 17 target entirely.
- **`@MainActor` isolation pushed to type level** — `Router`, `SheetCoordinator`, `RouterType`, `CoordinatorType`, and `TabCoordinatorType` now declare `@MainActor` at the class/protocol level. Per-method annotations have been removed.
- **Tab coordinator deduplication** — `TabCoordinator` now prevents the same child coordinator from being appended more than once.
- **`close()` helper** — New `close()` function on `CoordinatorType` simplifies dismissing the current coordinator without manually calling `finishFlow`.
- **Expanded test suite** — ~111 unit tests across all public APIs, including new files: `ItemManagerTests`, `SheetItemTests`, `TransitionPresentationStyleTests`, and expanded `CoordinatorTests`, `RouterTests`, and `TabCoordinatorTests`.

## Breaking Changes

- **`start(animated:)` → `start()`** — The `animated` parameter has been removed from `start()`. Animation is now handled per-navigation call.
- **`finishFlow` parameter removed from `close()`** — `close()` no longer accepts a `finishFlow` flag. Use `finishFlow(animated:)` directly when needed.
- **`popToView` removed** — The `popToView` navigation method has been removed. Use `popToRoot()` combined with targeted `navigate` calls instead.
- **`isTabCoordinable` removed from `Router`** — This internal property has been removed from the public API.
- **`SUICoordinator` now requires iOS 17** — The `SUICoordinator` target carries `@available(iOS 17.0, *)` throughout. Use `SUICoordinator16` for iOS 16 support.

---

## Migration Guide

### Switching from `SUICoordinator` (pre-1.0.1) on iOS 16

Replace the SPM dependency product:

```swift
// Before
.product(name: "SUICoordinator", package: "SUICoordinator")

// After (iOS 16+)
.product(name: "SUICoordinator16", package: "SUICoordinator")
```

Update view coordinator access:

```swift
// Before
@EnvironmentObject var coordinator: HomeCoordinator

// After (iOS 17, SUICoordinator)
@Environment(HomeCoordinator.self) var coordinator

// After (iOS 16, SUICoordinator16)
@EnvironmentObject var coordinator: HomeCoordinator  // unchanged
```

### Removing `animated` from `start()`

```swift
// Before
override func start() async {
    await startFlow(route: .home, animated: true)
}

// After
override func start() async {
    await startFlow(route: .home)
}
```
