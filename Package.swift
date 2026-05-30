// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "VibeBoard",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [
        .executable(name: "VibeBoard", targets: ["VibeBoard"]),
    ],
    targets: [
        .executableTarget(name: "VibeBoard"),
    ]
)
