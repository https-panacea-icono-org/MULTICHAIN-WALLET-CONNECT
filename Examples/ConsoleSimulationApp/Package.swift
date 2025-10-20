// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ConsoleSimulationApp",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    dependencies: [
        .package(path: "../..") // Referencia al paquete principal
    ],
    targets: [
        .executableTarget(
            name: "ConsoleSimulationApp",
            dependencies: [
                .product(name: "MultichainWalletConnect", package: "MULTICHAIN-WALLET-CONNECT")
            ]
        )
    ]
)
