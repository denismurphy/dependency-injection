// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "DependencyInjection",
    platforms: [.iOS(.v13),.tvOS(.v13),.watchOS(.v6),.macOS(.v11)],
    products: [
        .library(
            name: "DependencyInjection",
            targets: ["DependencyInjection"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DependencyInjection",
            dependencies: [])
    ],
    swiftLanguageVersions: [.v5]
)
