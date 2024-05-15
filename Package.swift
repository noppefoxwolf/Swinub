// swift-tools-version: 5.8
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


// Only development
/*
let warnConcurrency = "-warn-concurrency"
let enableActorDataRaceChecks = "-enable-actor-data-race-checks"
let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ImplicitOpenExistentials"),
    .enableUpcomingFeature("StrictConcurrency"),
    .unsafeFlags([
        warnConcurrency,
        enableActorDataRaceChecks,
    ]),
]

package.targets.forEach { target in
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(contentsOf: swiftSettings)
}
*/
