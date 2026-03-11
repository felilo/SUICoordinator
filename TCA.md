# SUICoordinator with The Composable Architecture (TCA)

TCA manages application state and business logic. SUICoordinator manages navigation. The two layers stay separate: the view receives a TCA `Store` for state and plain `async` closures for navigation actions.

---

## How It Works

- The coordinator is **never** placed in TCA state (`@ObservableState`, `@Shared`, or `@Dependency`). It is a reference-type object managing live UI — it cannot be serialized, diffed, or replayed.
- A private wrapper inside the route's `body` reads the coordinator from `@Environment(\.coordinator)`, creates the TCA `Store`, and passes both into the view.
- The view receives `StoreOf<Feature>` for state bindings and `() async -> Void` closures for navigation. It imports neither `SUICoordinator` nor knows about routes.
- Navigation closures are called directly from button/gesture handlers in the view — they do not go through the reducer.

---

## Example

### Route

The route's `body` is the only place where the coordinator and TCA meet.

```swift
import SwiftUI
import SUICoordinator
import ComposableArchitecture

enum ProductRoute: RouteType {
    case productList
    case productDetail(id: String, name: String)

    var presentationStyle: TransitionPresentationStyle {
        switch self {
            case .productList:  return .push
            case .productDetail: return .push
        }
    }

    @ViewBuilder
    var body: some View {
        switch self {
        case .productList:
            ProductListViewWrapper()
        case .productDetail(let id, let name):
            ProductDetailView(id: id, name: name)
        }
    }
}

// The wrapper is the only type that touches the coordinator.
// It is private to the route file and never exposed to the view layer.
private struct ProductListViewWrapper: View {
    @Environment(\.coordinator) private var anyCoordinator

    private var coordinator: ProductCoordinator? {
        anyCoordinator as? ProductCoordinator
    }

    var body: some View {
        if let coordinator {
            ProductListView(
                store: Store(initialState: ProductListFeature.State()) {
                    ProductListFeature()
                },
                onShowDetail: { id, name in
                    await coordinator.showDetail(id: id, name: name)
                }
            )
        }
    }
}
```

### Coordinator

```swift
import SUICoordinator

@Coordinator(ProductRoute.self)
class ProductCoordinator {

    func start() async {
        await startFlow(route: .productList)
    }

    func showDetail(id: String, name: String) async {
        await navigate(toRoute: .productDetail(id: id, name: name))
    }
}
```

### Reducer

The reducer owns state and handles data actions only. It has no knowledge of coordinators or navigation.

```swift
import ComposableArchitecture

@Reducer
struct ProductListFeature {

    @ObservableState
    struct State: Equatable {
        var products: [Product] = []
        var isLoading = false
    }

    enum Action {
        case loadProducts
        case productsLoaded([Product])
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadProducts:
                state.isLoading = true
                return .run { send in
                    let products = await ProductService.fetch()
                    await send(.productsLoaded(products))
                }

            case .productsLoaded(let products):
                state.isLoading = false
                state.products = products
                return .none
            }
        }
    }
}
```

### View

The view holds the TCA `Store` for state and receives closures for navigation. It imports neither `SUICoordinator` nor references any coordinator type.

```swift
import SwiftUI
import ComposableArchitecture

struct ProductListView: View {
    @Bindable var store: StoreOf<ProductListFeature>
    let onShowDetail: (_ id: String, _ name: String) async -> Void

    var body: some View {
        List(store.products) { product in
            Button(product.name) {
                Task { await onShowDetail(product.id, product.name) }
            }
        }
        .task { store.send(.loadProducts) }
        .navigationTitle("Products")
    }
}
```

### App Entry Point

```swift
import SwiftUI
import SUICoordinator

@main
struct MyApp: App {
    let coordinator = ProductCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.getView()
        }
    }
}
```

---

## Why the Coordinator Stays Outside State

TCA state must be value types that are equatable, serializable, and safe to replay during time-travel debugging. A coordinator is a reference-type object managing live UI state — it cannot satisfy any of these requirements. Keeping the coordinator out of state and out of the dependency system preserves TCA's guarantees while giving the coordinator full control over the navigation stack.

---

[← Back to README](README.md)
