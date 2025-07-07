// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swinub",
    platforms: [.iOS(.v16), .macOS(.v15)],
    products: [
        .library(
            name: "Swinub",
            targets: ["Swinub", "SwinubStreaming"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.4"),
        .package(url: "https://github.com/apple/swift-http-types", from: "1.4.0"),
        .package(url: "https://github.com/noppefoxwolf/CoreTransferableBackport", from: "0.0.3"),
    ],
    targets: [
        .target(
            name: "Swinub",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
                "CoreTransferableBackport",
            ],
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "SwinubStreaming",
            dependencies: ["Swinub"]
        ),
        .testTarget(
            name: "SwinubStreamingTests",
            dependencies: ["SwinubStreaming"]
        ),
        .testTarget(
            name: "SwinubTests",
            dependencies: ["Swinub"]
        ),
        .testTarget(
            name: "SwinubServerResponseTests",
            dependencies: ["Swinub"]
        ),
    ]
)

let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("ExistentialAny"),
    .enableExperimentalFeature("StrictConcurrency"),
]

package.targets.forEach { target in
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(contentsOf: swiftSettings)
}
