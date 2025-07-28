// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "WarmUp",
    products: [
        .library(
            name: "WarmUp",
            targets: ["WarmUp"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3")
    ],
    targets: [
        .target(
            name: "WarmUp",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics")
            ]
        ),
        .testTarget(
            name: "WarmUpTests",
            dependencies: [
                "WarmUp",
                .product(name: "Numerics", package: "swift-numerics")
            ]
        )
    ]
)
