// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SUICoordinator",
	platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
//		.executable(name: "SUICoordinator", targets: ["SUICoordinator"]),
        .library(
            name: "SUICoordinator",
            targets: ["SUICoordinator"]),
    ],
//	dependencies: [
//		.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
//		
//	],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
//		.executableTarget(name: "SUICoordinator")
        .target(
            name: "SUICoordinator"),
        .testTarget(
            name: "SUICoordinatorTests",
            dependencies: ["SUICoordinator"]),
    ]
)
