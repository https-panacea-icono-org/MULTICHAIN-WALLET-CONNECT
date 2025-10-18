// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AlamofireDemo",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "AlamofireDemo",
            targets: ["AlamofireDemo"]
        ),
    ],
    dependencies: [
        .package(path: "../../"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AlamofireDemo",
            dependencies: [
                .product(name: "MultichainWalletConnect", package: "MultichainWalletConnect"),
                .product(name: "Alamofire", package: "Alamofire")
            ]
        ),
    ]
)
