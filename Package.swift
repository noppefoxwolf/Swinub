// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swinub",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "Swinub",
            targets: ["Swinub", "SwinubStreaming"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-http-types", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "Swinub",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
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
    .enableExperimentalFeature("BareSlashRegexLiterals"),
    .enableExperimentalFeature("ConciseMagicFile"),
    .enableExperimentalFeature("ExistentialAny"),
    .enableExperimentalFeature("ForwardTrailingClosures"),
    .enableExperimentalFeature("ImplicitOpenExistentials"),
    .enableExperimentalFeature("StrictConcurrency"),

    .enableExperimentalFeature("ImportObjcForwardDeclarations"),
    .enableExperimentalFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("DeprecateApplicationMain"),
    .enableExperimentalFeature("IsolatedDefaultValues"),
    .enableExperimentalFeature("GlobalConcurrency"),
]

package.targets.forEach { target in
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(contentsOf: swiftSettings)
}
