// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WindowManager",
    products: [
        .library(
            name: "WindowManager",
            targets: ["WindowManager"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WindowManager",
            dependencies: []),
        .testTarget(
            name: "WindowManagerTests",
            dependencies: ["WindowManager"]),
    ]
)
