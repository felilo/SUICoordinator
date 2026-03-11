# SUICoordinator with Decoupled Views

Views receive plain async closures for navigation actions. They know nothing about coordinators, routes, or the SUICoordinator library itself.

---

## How It Works

- Views declare navigation actions as `() async -> Void` parameters in their `init`.
- The coordinator creates these closures and passes them when constructing the view inside the route's `body`.
- Views contain zero references to any coordinator type. They do not `import SUICoordinator`.
- The route's `body` is the only place where the coordinator and the view meet.

---

## Example

### Route

The route's `body` reads the coordinator from the environment and constructs the view with concrete closures. The view itself receives no coordinator reference.

```swift
import SwiftUI
import SUICoordinator

enum SettingsRoute: RouteType {
    case settings
    case profileDetail
    case helpSheet

    var presentationStyle: TransitionPresentationStyle {
        switch self {
            case .settings: return .push
            case .profileDetail: return .push
            case .helpSheet: return .sheet
        }
    }

    @ViewBuilder
    var body: some View {
        switch self {
        case .settings:
            SettingsViewWrapper()
        case .profileDetail:
            ProfileDetailView()
        case .helpSheet:
            HelpView()
        }
    }
}

// The wrapper is the only type that touches the coordinator.
// It is private to the route file and never exposed to the view layer.
private struct SettingsViewWrapper: View {
    @Environment(\.coordinator) private var anyCoordinator

    private var coordinator: SettingsCoordinator? {
        anyCoordinator as? SettingsCoordinator
    }

    var body: some View {
        if let coordinator {
            SettingsView(
                onPushDetail: { await coordinator.showProfileDetail() },
                onShowHelp: { await coordinator.showHelp() },
                onDismiss: { await coordinator.finishFlow() }
            )
        }
    }
}
```

### Coordinator

```swift
import SUICoordinator

@Coordinator(SettingsRoute.self)
class SettingsCoordinator {

    func start() async {
        await startFlow(route: .settings)
    }

    func showProfileDetail() async {
        await navigate(toRoute: .profileDetail)
    }

    func showHelp() async {
        await navigate(toRoute: .helpSheet)
    }
}
```

### View

The view holds no coordinator type. It receives closures and calls them. It can be compiled, previewed, and tested with no knowledge of SUICoordinator.

```swift
import SwiftUI

struct SettingsView: View {
    let onPushDetail: () async -> Void
    let onShowHelp: () async -> Void
    let onDismiss: () async -> Void

    var body: some View {
        List {
            Section("Account") {
                Button("Edit Profile") {
                    Task { await onPushDetail() }
                }
            }

            Section("Support") {
                Button("Help & FAQ") {
                    Task { await onShowHelp() }
                }
            }

            Section {
                Button("Close", role: .destructive) {
                    Task { await onDismiss() }
                }
            }
        }
        .navigationTitle("Settings")
    }
}
```

---

## Testability and Previews

Because the view depends only on closures, it can be exercised in complete isolation:

```swift
// Unit test — no coordinator, no environment, no SwiftUI rendering needed.
var pushDetailCalled = false
let view = SettingsView(
    onPushDetail: { pushDetailCalled = true },
    onShowHelp: { },
    onDismiss: { }
)

// Xcode Preview — pass static closures, no coordinator required.
#Preview {
    NavigationStack {
        SettingsView(
            onPushDetail: { },
            onShowHelp: { },
            onDismiss: { }
        )
    }
}
```

This approach also makes it straightforward to reuse a view in a different coordinator: supply different closures without changing the view at all.

---

[← Back to README](../README.md)
