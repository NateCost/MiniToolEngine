// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WY Mini Tool Engine",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "WY Mini Tool Engine",
            targets: ["WY Mini Tool Engine"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "WY Mini Tool Engine", path: "Sources"
        ),
        .testTarget(
            name: "WY Mini Tool EngineTests",
            dependencies: ["WY Mini Tool Engine"],
            path: "Tests"
        )
    ]
)
