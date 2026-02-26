// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SUICoordinator",
    platforms: [.iOS(.v16)],
    products: [
        // iOS 17+ layer using @Observable
        .library(
            name: "SUICoordinator",
            targets: ["SUICoordinator"]),
        // iOS 16+ layer using ObservableObject
        .library(
            name: "SUICoordinator16",
            targets: ["SUICoordinator16"]),
    ],
    targets: [
        // Shared pure value types, actors, and framework-agnostic helpers.
        // No observation APIs — safe for both iOS 16 and iOS 17+.
        .target(
            name: "SUICoordinatorCore",
            path: "Sources/SUICoordinatorCore"
        ),
        // iOS 17+ layer: @Observable classes, @State, @Bindable, .environment()
        // Consumers importing this product must set their deployment target to iOS 17+.
        .target(
            name: "SUICoordinator",
            dependencies: ["SUICoordinatorCore"],
            path: "Sources/SUICoordinator"
        ),
        // iOS 16+ layer: ObservableObject, @Published, @StateObject, .environmentObject()
        .target(
            name: "SUICoordinator16",
            dependencies: ["SUICoordinatorCore"],
            path: "Sources/SUICoordinator16"
        ),
        .testTarget(
            name: "SUICoordinatorTests",
            dependencies: ["SUICoordinator16"]),
    ]
)
