// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SUICoordinator",
	platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "SUICoordinator",
            targets: ["SUICoordinator"]),
    ],
    targets: [
        .target(
            name: "SUICoordinator"),
        .testTarget(
            name: "SUICoordinatorTests",
            dependencies: ["SUICoordinator"]),
    ]
)
