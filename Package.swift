// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BezelNotification",
    platforms: [.macOS(.v10_14)],
    products: [
        .library(
            name: "BezelNotification",
            targets: ["BezelNotification"]),
    ],
    targets: [
        .target(
            name: "BezelNotification",
            dependencies: []),
    ]
)
