// swift-tools-version: 5.10

import AppleProductTypes
import PackageDescription

let package = Package(
    name: "Playground",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .iOSApplication(
            name: "Playground",
            targets: ["AppModule"],
            bundleIdentifier: "DFAB0509-E6F9-4BF8-8FAA-8EAE1E7E9B27",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            supportedDeviceFamilies: [
                .pad,
                .phone,
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad])),
            ]
        )
    ],

    dependencies: [
        .package(path: "../")
    ],

    targets: [
        .executableTarget(
            name: "AppModule",

            dependencies: [
                .product(
                    name: "Swinub",
                    package: "Swinub"
                )
            ],

            path: "."
        )
    ]
)
