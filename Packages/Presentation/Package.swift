// swift-tools-version: 6.0
// ── FILE: Packages/Presentation/Package.swift ──
import PackageDescription

let package = Package(
    name: "Presentation",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "Presentation", targets: ["Presentation"])
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "Presentation",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "Domain", package: "Domain")
            ],
            path: "Sources/Presentation"
        ),
        .testTarget(
            name: "PresentationTests",
            dependencies: ["Presentation"],
            path: "Tests/PresentationTests"
        )
    ]
)
