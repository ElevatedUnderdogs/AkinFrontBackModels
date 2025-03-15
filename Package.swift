// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "AkinFrontBackModels",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "AkinFrontBack",
            targets: ["AkinFrontBack"]
        ),
        .library(
            name: "AkinFrontBackServer",
            targets: ["AkinFrontBackServer"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/scott-lydon/EncryptDecryptKey.git", from: "1.0.2"),
        .package(url: "https://github.com/scott-lydon/StrongContractClient.git", from: "9.1.0"),
    ],
    targets: [
        .target(
            name: "AkinFrontBack",
            dependencies: [
                "EncryptDecryptKey",
                .product(name: "StrongContract", package: "StrongContractClient")
            ]
        ),
        .target(
            name: "AkinFrontBackServer",
            dependencies: [
                "AkinFrontBack", // ✅ Now correctly depends on AkinFrontBack
                "EncryptDecryptKey",
                .product(name: "StrongContract", package: "StrongContractClient"),
                .product(name: "StrongContractServer", package: "StrongContractClient", condition: .when(platforms: [.macOS, .linux]))
            ]
        ),
        .testTarget(
            name: "AkinFrontBackTests",
            dependencies: ["AkinFrontBack"]
        ),
    ]
)
