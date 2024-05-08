// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "spi-s6-preview-analysis",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.1"),  
    ],
    targets: [
        .executableTarget(
            name: "spi-s6-preview-analysis",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Analysis"
            ],
            path: "Sources/Executable"
        ),
        .target(name: "Analysis"),
        .testTarget(name: "AnalysisTests", dependencies: ["Analysis"])
    ]
)
