// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SimulationApp",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    dependencies: [
        .package(path: "..")
    ],
    targets: [
        .executableTarget(
            name: "SimulationApp",
            dependencies: [
                .product(name: "MultichainWalletConnect", package: "MULTICHAIN-WALLET-CONNECT")
            ]
        )
    ]
)
