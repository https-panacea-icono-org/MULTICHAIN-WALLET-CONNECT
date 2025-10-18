// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MultichainWalletConnect",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "MultichainWalletConnect",
            targets: ["MultichainWalletConnect"]
        ),
    ],
    dependencies: [
        // WalletConnect Swift SDK - Comentado temporalmente por problemas de compilación
        // .package(url: "https://github.com/WalletConnect/WalletConnectSwift.git", from: "1.0.0"),
        
        // Algorand Swift SDK - Comentado temporalmente por problemas de compilación
        // .package(url: "https://github.com/algorand/swift-algorand-sdk.git", from: "2.0.0"),
        
        // QR Code generation
        .package(url: "https://github.com/apple/swift-crypto.git", from: "2.0.0"),
        
        // JSON Web Tokens
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0"),
        
        // Networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "MultichainWalletConnect",
            dependencies: [
                // .product(name: "WalletConnectSwift", package: "WalletConnectSwift"), // Comentado temporalmente
                // .product(name: "AlgorandSDK", package: "swift-algorand-sdk"), // Comentado temporalmente
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "Alamofire", package: "Alamofire")
            ],
            path: "Sources"
        ),
    ]
)
