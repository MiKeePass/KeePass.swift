// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KeePass",
    platforms: [.iOS(.v13), .macOS(.v10_12)],

    products: [
        // The `Binary` manipulate bytes with ease.
        .library(
            name: "Binary",
            targets: ["Binary"]),

        // `Crypto` defines cryptographic interfaces used by KeePass.
        .library(
            name: "Crypto",
            targets: ["Crypto"]),

        // `KeePass` library defines interfaces to work with KeePass files.
        .library(
            name: "KeePass",
            targets: ["KeePass"]),
    ],

    targets: [

        .target(
            name: "KeePass",
            dependencies: [ "Binary",
                            "KDB",
                            "KDBX"]),

        .target(
            name: "KDB",
            dependencies: [ "Binary",
                            "Crypto"]),

        .target(
            name: "KDBX",
            dependencies: [ "Binary",
                            "Crypto",
                            "Gzip",
                            "XML"]),

        .target(
            name: "Binary",
            dependencies: []),
        .testTarget(
            name: "BinaryTests",
            dependencies: ["Binary"]),

        .target(
            name: "Crypto",
            dependencies: [ "Binary", 
                            "Sodium", 
                            "Argon2", 
                            "Twofish"]),

        .target(
            name: "Gzip",
            dependencies: ["Binary"]),

        .target(
            name: "XML",
            dependencies: []),

        // MARK: KeePass cryptographic libraries

        .target(
            name: "Sodium",
            dependencies: [],
            cSettings: [
                .headerSearchPath("include/sodium"),
                .define("CONFIGURED")
            ]),

        .target(
            name: "Argon2",
            dependencies: []),

        .target(
            name: "Twofish",
            dependencies: []),
    ]
)
