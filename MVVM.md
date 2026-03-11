# SUICoordinator with MVVM

The coordinator handles navigation; the ViewModel handles business logic. Each has a single responsibility, and neither bleeds into the other's domain.

---

## How It Works

- The ViewModel holds business logic and owns all state the view needs to render.
- The coordinator is injected into the ViewModel at construction time — not accessed via `@Environment` inside the ViewModel.
- The view holds the ViewModel as `@State` and only calls ViewModel methods. It never calls the coordinator directly.
- The coordinator is retrieved from `@Environment` inside the route's `body`, then passed into the ViewModel's `init`.

---

## Example

### Route

The route's `body` is the bridge between the coordinator and the ViewModel. It reads the coordinator from the environment, constructs the ViewModel with it, and hands both to the view.

```swift
import SwiftUI
import SUICoordinator

enum ProductRoute: RouteType {
    case productList
    case productDetail(id: String, name: String)

    var presentationStyle: TransitionPresentationStyle {
        switch self {
            case .productList: return .push
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

// Wrapper reads the coordinator from the environment and constructs the ViewModel.
private struct ProductListViewWrapper: View {
    @Environment(\.coordinator) private var anyCoordinator

    private var coordinator: ProductCoordinator? {
        anyCoordinator as? ProductCoordinator
    }

    var body: some View {
        if let coordinator {
            ProductListView(viewModel: ProductListViewModel(coordinator: coordinator))
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

    func showFilterSheet() async {
        await navigate(toRoute: .productList, presentationStyle: .detents([.medium]))
    }
}
```

### ViewModel

```swift
import Foundation

@Observable
class ProductListViewModel {
    private let coordinator: ProductCoordinator

    var products: [Product] = []
    var isLoading = false

    init(coordinator: ProductCoordinator) {
        self.coordinator = coordinator
    }

    func loadProducts() async {
        isLoading = true
        products = await ProductService.fetch()
        isLoading = false
    }

    func selectProduct(_ product: Product) async {
        await coordinator.showDetail(id: product.id, name: product.name)
    }

    func openFilters() async {
        await coordinator.showFilterSheet()
    }
}
```

### View

The view holds the ViewModel as `@State` and delegates every action to it. There is no coordinator import and no direct coordinator call.

```swift
import SwiftUI

struct ProductListView: View {
    @State var viewModel: ProductListViewModel

    var body: some View {
        List(viewModel.products) { product in
            Button(product.name) {
                Task { await viewModel.selectProduct(product) }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Filter") {
                    Task { await viewModel.openFilters() }
                }
            }
        }
        .task { await viewModel.loadProducts() }
        .navigationTitle("Products")
    }
}
```

---

## Testability

Because the coordinator is injected into the ViewModel, you can replace it with a mock in unit tests without touching SwiftUI at all:

```swift
final class MockProductCoordinator: ProductCoordinator {
    var showDetailCalled = false

    override func showDetail(id: String, name: String) async {
        showDetailCalled = true
    }
}

// In your test:
let mock = MockProductCoordinator()
let viewModel = ProductListViewModel(coordinator: mock)
await viewModel.selectProduct(Product(id: "1", name: "Test"))
XCTAssertTrue(mock.showDetailCalled)
```

No `XCTestExpectation`, no view rendering, no environment setup required.

---

[← Back to README](README.md)
