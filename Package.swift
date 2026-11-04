// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Vector",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v8),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "Vector",
            targets: ["Vector"]),
    ],
    dependencies: [
        .package(url: "https://github.com/heestand-xyz/PixelColor", from: "3.3.0"),
        .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", from: "2.2.0"),
        .package(url: "https://github.com/nicklockwood/SVGPath", from: "1.1.4"),
    ],
    targets: [
        .target(
            name: "Vector",
            dependencies: [
                "CoreGraphicsExtensions",
                "SVGPath",
                "PixelColor",
            ]),
        .testTarget(
            name: "VectorTests",
            dependencies: ["Vector"],
            exclude: ["SVG/SVG_Logo.current.png"],
            resources: [
                .copy("SVG/SVG_Logo.svg"),
                .copy("SVG/SVG_Logo.expected.png"),
            ])
    ]
)
