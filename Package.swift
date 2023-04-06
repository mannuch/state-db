// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "state-db",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "StateDB",
            targets: ["StateDB"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.40.0"),
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/yaslab/ULID.swift.git", .upToNextMinor(from: "1.2.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "StateDB",
            dependencies: [
              .product(name: "FluentKit", package: "fluent-kit"),
              .product(name: "FluentMySQLDriver", package: "fluent-mysql-driver"),
              .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
              .product(name: "ULID", package: "ULID.swift"),
            ]
        ),
        .executableTarget(
            name: "Migrator",
            dependencies: ["StateDB"]
        ),
        .testTarget(
            name: "StateDBTests",
            dependencies: ["StateDB"]
        ),
    ]
)
