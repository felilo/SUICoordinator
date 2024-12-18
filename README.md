# SUICoordinator

This repository contains a library that implements the Coordinator pattern, which is a design pattern used in iOS application development to manage application navigation flows. The library provides a set of features that can be used to implement the Coordinators flow. This library does not use any UIKit components.
_____

## Getting Started

To use the SUICoordinator library in your iOS project, you'll need to add the library files to your project. Here are the basic steps:
_____

## Defining the coordinator
First let's define the paths and views.

<br>

```swift
import SwiftUI
import SUICoordinator

enum HomeRoute: RouteType {
    
    case push(viewModel: PushViewModel)
    case sheet(viewModel: SheetViewModel)
    case fullscreen(viewModel: FullscreenViewModel)
    case detents(viewModel: DetentsViewModel)
    case actionListView(viewModel: ActionListViewModel)
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
            case .push:
                return .push
            case .sheet:
                return .sheet
            case .fullscreen:
                return .fullScreenCover
            case .detents:
                return .detents([.medium])
            case .actionListView:
                return .push
        }
    }

    @ViewBuilder
    var view: Body {
        switch self {
            case .push(let viewModel):
                PushView(viewModel: viewModel)
            case .sheet(let viewModel):
                SheetView(viewModel: viewModel)
            case .fullscreen(let viewModel):
                FullscreenView(viewModel: viewModel)
            case .detents(let viewModel):
                DetentsView(viewModel: viewModel)
            case .actionListView(let viewModel):
                NavigationActionListView(viewModel: viewModel)
        }
    }
}
```

Second let's create the first Coordinator. All coordinator should to implement the ``start()`` function and then starts the flow (mandatory). Finally, add additional flows

```swift
import SUICoordinator

class HomeCoordinator: Coordinator<HomeRoute> {
    
    override func start(animated: Bool = true) async {
        let viewModel = ActionListViewModel(coordinator: self)
        await startFlow(route: .actionListView(viewModel: viewModel), animated: animated)
    }
    
    func navigateToPushView() async {
        let viewModel = PushViewModel(coordinator: self)
        await router.navigate(to: .push(viewModel: viewModel))
    }
    
    func presentSheet() async {
        let viewModel = SheetViewModel(coordinator: self)
        await router.navigate(to: .sheet(viewModel: viewModel))
    }
    
    func presentFullscreen() async {
        let viewModel = FullscreenViewModel(coordinator: self)
        await router.navigate(to: .fullscreen(viewModel: viewModel))
    }
    
    func presentDetents() async {
        let viewModel = DetentsViewModel(coordinator: self)
        await router.navigate(to: .detents(viewModel: viewModel))
    }
    
    func presentTabbarCoordinator() async {
        let coordinator = CustomTabbarCoordinator()
        await navigate(to: coordinator, presentationStyle: .sheet)
    }
    
    func close() async {
        await router.close()
    }
    
    func finsh() async {
        await finishFlow(animated: true)
    }
}
```

Then let's create a View and its ViewModel


```swift
import Foundation

class ActionListViewModel: ObservableObject {
    
    let coordinator: HomeCoordinator
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }
    
    @MainActor func navigateToFirstView() async {
        await coordinator.navigateToPushView()
    }
    
    @MainActor func presentSheet() async {
        await coordinator.presentSheet()
    }
    
    @MainActor func presentFullscreen() async {
        await coordinator.presentFullscreen()
    }
    
    @MainActor func presentDetents() async {
        await coordinator.presentDetents()
    }
    
    @MainActor func presentTabbarCoordinator() async {
        await coordinator.presentTabbarCoordinator()
    }
    
    @MainActor func finish() async {
        await coordinator.finish()
    }
}
```

```swift
import SwiftUI

struct NavigationActionListView: View {
    
    typealias ViewModel = ActionListViewModel
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        List {
            Button("Push NavigationView") {
                Task { await viewModel.navigateToPushView() }
            }
            
            Button("Presents SheetView") {
                Task { await viewModel.presentSheet() }
            }
            
            Button("Presents FullscreenView") {
                Task { await viewModel.presentFullscreen() }
            }
            
            Button("Presents DetentsView") {
                Task { await viewModel.presentDetents() }
            }
            
            Button("Presents Tabbar Coordinator") {
                Task { await viewModel.presentTabbarCoordinator() }
            }
        }
        .navigationTitle("Navigation Action List")
    }
}
```
_____

### Setup project

<br>

1. Create an AppDelegate class and do the following implementation or if you prefer skip this step and do the same implementation in the next step.

```swift
import SwiftUI
import SUICoordinator

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var mainCoodinator: HomeCoordinator?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        mainCoodinator = HomeCoordinator()


        // Simulate the receipt of a notification or external trigger to present some coordinator
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            Task { [weak self] in
                // Create and present the CustomTabbarCoordinator in a sheet presentation style
                let coordinator = CustomTabbarCoordinator()
                try? await coordinator.forcePresentation(
                    presentationStyle: .sheet,
                    mainCoordinator: self
                )
            }
        }


        return true
    }
}
```

<br>

2. In the App file, Follow next implementation:

```swift
import SwiftUI

@main
struct SUICoordinatorDemoApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            appDelegate.mainCoodinator?.getView()
        }
    }
}
```

### Example project

For better understanding, I recommend that you take a look at the example project located in the [Example folder](https://github.com/felilo/SUICoordinator/tree/main/Examples/SUICoordinatorExample).

https://github.com/felilo/SUICoordinator/assets/10853689/90e8564e-6fa5-458b-b2a3-23d10f5aebb4

_____

### Features

These are the most important features and actions that you can perform:
<br>


#### RouteType

To create any route in `SUICoordinator` you need to extend your object to the `RouteType` protocol; Additionally, you can add your custom functions if you need. As you can see, in our example we are using custom types (`enums`) to implement it.

Last but not least, you can also use `DefaultRoute` to create custom routes as demonstrated in the `TabBarFlowCoordinator` [example](https://github.com/felilo/SUICoordinator/blob/main/Examples/SUICoordinatorExample/SUICoordinatorExample/Coordinators/TabbarFlow/TabbarFlowCoordinator.swift)
<br>


#### Router

The router is encharge to manage the navigation stack and coordinate the transitions between different views. It abstracts away the navigation details from the views, allowing them to focus on their specific features such as:

<br>
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Parametes</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code style="color: blue;">navigate(_)</code></td>
      <td>
        <ul cellspacing="0" cellpadding="0">
          <li><b>to:</b> <code>Route</code>,</li>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code>, default: <code style="color: #ec6b6f;">nil</code>,</li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Is an async function, allows you to navigate among the views that were defined in the Route. The types of presentation are Push, Sheet, Fullscreen and Detents</td>
    </tr>
    <tr>
      <td><code style="color: blue;">present(_)</code></td>
      <td> 
        <ul>
          <li><b>_ view:</b> <code>ViewType</code></li>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code>, default: <code style="color: #ec6b6f;">nil</code>,</li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Is an async function, presents a view such as Sheet, Fullscreen or Detents</td>
    </tr>
    <tr>
      <td><code style="color: blue;">pop(_)</code></td>
      <td> 
        <ul>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Is an async function, pops the top view from the navigation stack and updates the display.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">popToRoot(_)</code></td>
      <td> 
        <ul>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Is an async function, pops all the views on the stack except the root view and updates the display.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">dismiss(_)</code></td>
      <td> 
        <ul>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Is an async function, dismisses the view that was presented modally by the view.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">popToView(_)</code></td>
      <td> 
        <ul>
          <li><b>_ view:</b> <code>T</code></li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Is an async function, pops views until the specified view is at the top of the navigation stack. Example: <code>router.popToView(MyView.self)</code></td>
    </tr>
    <tr>
      <td><code style="color: blue;">close(_)</code></td>
      <td> 
        <ul>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Is an async function, dismiss or pops the last view presented in the Coordinator.</td>
    </tr>
  </tbody>
</table>
<br>

#### Coordinator

Acts as a separate entity from the views, decoupling the navigation logic from the presentation logic. This separation of concerns allows the views to focus solely on their specific functionalities, while the Navigation Coordinator takes charge of the app's overall navigation flow. Some features are:

<br>
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Parametes</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code style="color: blue;">router</code></td>
      <td></td>
      <td>Variable of Route type which allow performs action router.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">startFlow(_)</code></td>
      <td> 
        <ul>
          <li><b>to:</b> <code>Route</code></li>
          <li><b>transitionStyle:</b> <code>TransitionPresentationStyle?</code>, default: <code style="color: #ec6b6f;">automatic</code>,</li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Is an async function, cleans the navigation stack and runs the navigation flow.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">finishFlow(_)</code></td>
      <td> 
        <ul>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Is an async function, pops all the views on the stack including the root view, dismisses all the modal view and remove the current coordinator from the coordinator stack.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">forcePresentation(_)</code></td>
      <td> 
        <ul>
          <li><b>route:</b> <code>Route</code></li>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code>, default: <code style="color: #ec6b6f;">automatic</code>,</li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
          <li><b>mainCoordinator:</b> <code>Coordinator?</code>, default: <code style="color: #ec6b6f;">mainCoordinator</code></li>
        </ul>
      </td>
      <td>Is an async function, puts the current coordinator at the top of the coordinator stack, making it the active and visible coordinator. This feature is very useful to start the navigation flow from push notifications, notification center, atypical flows, etc.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">navigate(_)</code></td>
      <td> 
        <ul>
          <li><b>to:</b> <code>Coordinator</code></li>
          <li><b>presentationStyle:</b> <code>TransitionPresentationStyle?</code>, default: <code style="color: #ec6b6f;">automatic</code>,</li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Is an async function, allows you to navigate among the Coordinators. It calls the <code>start()</code> function.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">finishFlow(_)</code></td>
      <td> 
        <ul>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Is an async function, pops all the views on the stack including the root view, dismisses all the modal view and remove the current coordinator from the coordinator stack.</td>
    </tr>
  </tbody>
</table>
<br>

#### TabbarCoordinator

It works the same as Coordinator but has the following additional features:

<br>
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Parametes</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code style="color: blue;">currentPage</code></td>
      <td></td>
      <td>Variable of <code style="color: #ec6b6f;">Page</code> type which allow set and get the tab selected</td>
    </tr>
    <tr>
      <td><code style="color: blue;">getCoordinatorSelected()</code></td>
      <td> 
        <ul>
          <li><b>mainCoordinator:</b> <code>Coordinator?</code>, default <code style="color: #ec6b6f;">mainCoordinator</code>,</li>
        </ul>
      </td>
      <td>Returns the coordinator selected that is associated to the selected tab</td>
    </tr>
    <tr>
      <td><code style="color: blue;">setPages(_)</code></td>
      <td> 
        <ul>
          <li><b>_values:</b> <code>[PAGE]?</code>, default <code style="color: #ec6b6f;">mainCoordinator</code>,</li>
        </ul>
      </td>
      <td>Is an async function, updates the page set.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">getCoordinator(_)</code></td>
      <td> 
        <ul>
          <li><b>position:</b> <code>Int</code></li>
        </ul>
      </td>
      <td>Returns the coordinator at the position given as parameter</td>
    </tr>
    <tr>
      <td><code style="color: blue;">setBadge</code></td>
      <td>
        <ul>
          <li><b>PassthroughSubject:</b> <code>(String?, Page)?</code></li>
        </ul>
      </td>
      <td>Variable that allows set the badge of a tab</td>
    </tr>
    <tr>
      <td><code style="color: blue;">customView</code></td>
      <td>
        <ul>
          <li><b>view:</b> <code>View</code></li>
        </ul>
      </td>
      <td>Is a closure that receives a view as parameter, to create a custom tab bar </td>
    </tr>
  </tbody>
</table>

_____

### Installation 💾

SPM

Open Xcode and your project, click File / Swift Packages / Add package dependency... . In the textfield "Enter package repository URL", write <https://github.com/felilo/SUICoordinator> and press Next twice
_____

## Contributing

Contributions to the SUICoordinator library are welcome! To contribute, simply fork this repository and make your changes in a new branch. When your changes are ready, submit a pull request to this repository for review.
