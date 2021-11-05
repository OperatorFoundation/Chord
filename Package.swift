// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chord",
    platforms: [.macOS(.v10_15), .iOS(.v14)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Chord",
            targets: ["Chord"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Datable", url: "https://github.com/OperatorFoundation/Datable", from: "3.1.1"),
        .package(url: "https://github.com/OperatorFoundation/SwiftQueue", from: "0.1.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Chord",
            dependencies: ["SwiftQueue"]),
        .testTarget(
            name: "ChordTests",
            dependencies: ["Chord", "Datable"]),
    ],
    swiftLanguageVersions: [.v5]
)
