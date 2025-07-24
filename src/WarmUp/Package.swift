// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "WarmUp",
    products: [],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.3")
    ],
    targets: [
        .testTarget(
            name: "WarmUpTests",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics")
            ]
        )
    ]
)
