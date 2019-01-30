// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "ModelResponse",
    products: [
        .library(name: "ModelResponse", targets: ["ModelResponse"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.1.1")
    ],
    targets: [
        .target(name: "ModelResponse", dependencies: ["Vapor"]),
        .testTarget(name: "ModelResponseTests", dependencies: ["ModelResponse"]),
    ]
)