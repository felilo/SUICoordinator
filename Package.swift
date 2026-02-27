// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SUICoordinator",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "SUICoordinatorCore",
            targets: ["SUICoordinatorCore"]),
        .library(
            name: "SUICoordinator",
            targets: ["SUICoordinator"]),
        .library(
            name: "SUICoordinator16",
            targets: ["SUICoordinator16"]),
    ],
    targets: [
        .target(
            name: "SUICoordinatorCore"),
        .target(
            name: "SUICoordinator",
            dependencies: ["SUICoordinatorCore"]),
        .target(
            name: "SUICoordinator16",
            dependencies: ["SUICoordinatorCore"]),
        .testTarget(
            name: "SUICoordinatorTests",
            dependencies: ["SUICoordinator"]),
    ]
)
