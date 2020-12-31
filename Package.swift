// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "BiometricAuthentication",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "BiometricAuthentication",
            targets: ["BiometricAuthentication"]
        ),
    ],
    targets: [
        .target(
            name: "BiometricAuthentication",
            dependencies: []
        ),
        .testTarget(
            name: "BiometricAuthenticationTests",
            dependencies: ["BiometricAuthentication"]
        ),
    ]
)
