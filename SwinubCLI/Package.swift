// swift-tools-version: 6.3

import Foundation
import PackageDescription

let swinubPackageName = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .lastPathComponent

let package = Package(
    name: "SwinubCLI",
    platforms: [.macOS(.v15)],
    products: [
        .executable(
            name: "swinub-cli",
            targets: ["SwinubCLI"]
        )
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.20.0"),
    ],
    targets: [
        .executableTarget(
            name: "SwinubCLI",
            dependencies: [
                .product(name: "Swinub", package: swinubPackageName),
                .product(name: "SwinubAuthenticationServices", package: swinubPackageName),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Hummingbird", package: "hummingbird"),
            ]
        )
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
