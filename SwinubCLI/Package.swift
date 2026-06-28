// swift-tools-version: 6.3

import PackageDescription

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
    ],
    targets: [
        .executableTarget(
            name: "SwinubCLI",
            dependencies: [
                .product(name: "Swinub", package: "Swinub"),
                .product(name: "SwinubAuthenticationServices", package: "Swinub"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
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
