// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iPhoneSimulationApp",
    platforms: [
        .iOS(.v17), // iPhone 17 y iPhone 17 Pro requieren iOS 17+
        .macOS(.v14) // macOS compatible
    ],
    dependencies: [
        .package(path: "../..") // Referencia al paquete principal
    ],
    targets: [
        .executableTarget(
            name: "iPhoneSimulationApp",
            dependencies: [
                .product(name: "MultichainWalletConnect", package: "MULTICHAIN-WALLET-CONNECT")
            ]
        )
    ]
)
