// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SUICoordinator",
    platforms: [.iOS(.v16), .macOS(.v14)],
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
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .target(
            name: "SUICoordinatorCore"),
        .target(
            name: "SUICoordinator",
            dependencies: [
                "SUICoordinatorCore",
                "SUICoordinatorMacros",
            ]),
        .target(
            name: "SUICoordinator16",
            dependencies: ["SUICoordinatorCore"]),
        .macro(
            name: "SUICoordinatorMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "SUICoordinatorTests",
            dependencies: ["SUICoordinator"]),
        .testTarget(
            name: "SUICoordinatorMacroTests",
            dependencies: [
                "SUICoordinatorMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
