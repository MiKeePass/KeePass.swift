// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KeePass",
    platforms: [.iOS(.v13), .macOS(.v10_15)],

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
        .testTarget(
            name: "KeePassTests",
            dependencies: ["KeePass"],
            resources: [ .process("Fixtures") ]),

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
        .testTarget(
            name: "CryptoTests",
            dependencies: ["Crypto"]),

        .target(
            name: "Gzip",
            dependencies: ["Binary"],
            exclude: ["LICENSE"]),

        .target(
            name: "XML",
            dependencies: []),

        // MARK: KeePass Cryptographic Libraries

        .target(
            name: "Sodium",
            dependencies: [],
            exclude: ["LICENSE"],
            cSettings: [
                .headerSearchPath("include/sodium"),
                .define("CONFIGURED")
            ]),

        .target(
            name: "Argon2",
            dependencies: [],
            exclude: ["LICENSE"]),

        .target(
            name: "Twofish",
            dependencies: []),
    ]
)
