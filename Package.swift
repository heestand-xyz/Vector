// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Vector",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Vector",
            targets: ["Vector"]),
    ],
    dependencies: [
        .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", from: "1.7.1"),
    ],
    targets: [
        .target(
            name: "Vector",
            dependencies: ["CoreGraphicsExtensions"]),
    ]
)
