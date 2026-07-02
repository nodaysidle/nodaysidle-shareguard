// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ShareGuard",
    platforms: [.macOS(.v14)],
    products: [
        .executable(
            name: "ShareGuard",
            targets: ["ShareGuard"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ShareGuard",
            path: "Sources/ShareGuard",
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ShareGuardTests",
            dependencies: ["ShareGuard"],
            path: "Tests/ShareGuardTests",
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
