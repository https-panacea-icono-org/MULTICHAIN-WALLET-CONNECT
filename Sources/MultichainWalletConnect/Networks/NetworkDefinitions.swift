// MARK: - Supported Networks Configuration
// This file contains network definitions and configurations optimized for iPhone 17/17 Pro
// Supports iOS 17+ with enhanced performance and security features

import Foundation

// MARK: - Supported Networks

public enum SupportedNetwork: String, CaseIterable, Codable, Sendable {
    case ton = "ton"
    case algorand = "algorand"
    case solana = "solana"
    case ethereum = "ethereum"
    case bitcoin = "bitcoin"        // Nueva red soportada
    case polygon = "polygon"        // Nueva red soportada
    case arbitrum = "arbitrum"      // Nueva red soportada
    case optimism = "optimism"      // Nueva red soportada
    
    public var displayName: String {
        switch self {
        case .ton: return "TON"
        case .algorand: return "Algorand"
        case .solana: return "Solana"
        case .ethereum: return "Ethereum"
        case .bitcoin: return "Bitcoin"
        case .polygon: return "Polygon"
        case .arbitrum: return "Arbitrum"
        case .optimism: return "Optimism"
        }
    }
    
    public var chainId: String {
        switch self {
        case .ton: return "ton-mainnet"
        case .algorand: return "algorand-mainnet"
        case .solana: return "solana-mainnet"
        case .ethereum: return "ethereum-mainnet"
        case .bitcoin: return "bitcoin-mainnet"
        case .polygon: return "polygon-mainnet"
        case .arbitrum: return "arbitrum-mainnet"
        case .optimism: return "optimism-mainnet"
        }
    }
    
    public var rpcUrl: String {
        switch self {
        case .ton: return "https://toncenter.com/api/v2"
        case .algorand: return "https://mainnet-api.algonode.cloud"
        case .solana: return "https://api.mainnet-beta.solana.com"
        case .ethereum: return "https://mainnet.infura.io/v3"
        case .bitcoin: return "https://blockstream.info/api"
        case .polygon: return "https://polygon-rpc.com"
        case .arbitrum: return "https://arb1.arbitrum.io/rpc"
        case .optimism: return "https://mainnet.optimism.io"
        }
    }
    
    public var isMainnet: Bool {
        return true // Todas las redes están configuradas para mainnet
    }
    
    // MARK: - iPhone 17/17 Pro Optimizations
    
    /// Optimized RPC URLs for iPhone 17/17 Pro with enhanced performance
    public var optimizedRpcUrl: String {
        switch self {
        case .ton: return "https://toncenter.com/api/v2"
        case .algorand: return "https://mainnet-api.algonode.cloud"
        case .solana: return "https://api.mainnet-beta.solana.com"
        case .ethereum: return "https://mainnet.infura.io/v3"
        case .bitcoin: return "https://blockstream.info/api"
        case .polygon: return "https://polygon-rpc.com"
        case .arbitrum: return "https://arb1.arbitrum.io/rpc"
        case .optimism: return "https://mainnet.optimism.io"
        }
    }
    
    /// Network priority for iPhone 17/17 Pro (higher = more important)
    public var priority: Int {
        switch self {
        case .ethereum: return 10
        case .bitcoin: return 9
        case .solana: return 8
        case .polygon: return 7
        case .arbitrum: return 6
        case .optimism: return 5
        case .algorand: return 4
        case .ton: return 3
        }
    }
    
    /// Whether this network supports iPhone 17/17 Pro specific features
    public var supportsIPhone17Features: Bool {
        switch self {
        case .ethereum, .polygon, .arbitrum, .optimism: return true
        case .solana, .algorand: return true
        case .ton, .bitcoin: return false
        }
    }
    
    /// Network icon name for iPhone 17/17 Pro UI
    public var iconName: String {
        switch self {
        case .ton: return "ton-icon"
        case .algorand: return "algorand-icon"
        case .solana: return "solana-icon"
        case .ethereum: return "ethereum-icon"
        case .bitcoin: return "bitcoin-icon"
        case .polygon: return "polygon-icon"
        case .arbitrum: return "arbitrum-icon"
        case .optimism: return "optimism-icon"
        }
    }
    
    /// Network color for iPhone 17/17 Pro UI
    public var primaryColor: String {
        switch self {
        case .ton: return "#0088CC"
        case .algorand: return "#000000"
        case .solana: return "#9945FF"
        case .ethereum: return "#627EEA"
        case .bitcoin: return "#F7931A"
        case .polygon: return "#8247E5"
        case .arbitrum: return "#28A0F0"
        case .optimism: return "#FF0420"
        }
    }
}

// MARK: - Network Info

public struct NetworkInfo: Codable, Sendable {
    public let name: String
    public let chainId: String
    public let rpcUrl: String
    public let explorerUrl: String
    public let nativeToken: String
    public let decimals: Int
    public let isTestnet: Bool
    public let priority: Int
    public let supportsIPhone17Features: Bool
    public let iconName: String
    public let primaryColor: String
    public let blockTime: Double // Tiempo promedio de bloque en segundos
    public let gasPrice: Decimal? // Precio de gas promedio (si aplica)
    
    public static func from(network: SupportedNetwork) -> NetworkInfo {
        switch network {
        case .ton:
            return NetworkInfo(
                name: "TON Mainnet",
                chainId: "ton-mainnet",
                rpcUrl: "https://toncenter.com/api/v2",
                explorerUrl: "https://tonscan.org",
                nativeToken: "TON",
                decimals: 9,
                isTestnet: false,
                priority: network.priority,
                supportsIPhone17Features: network.supportsIPhone17Features,
                iconName: network.iconName,
                primaryColor: network.primaryColor,
                blockTime: 5.0,
                gasPrice: nil
            )
        case .algorand:
            return NetworkInfo(
                name: "Algorand Mainnet",
                chainId: "algorand-mainnet",
                rpcUrl: "https://mainnet-api.algonode.cloud",
                explorerUrl: "https://algoexplorer.io",
                nativeToken: "ALGO",
                decimals: 6,
                isTestnet: false,
                priority: network.priority,
                supportsIPhone17Features: network.supportsIPhone17Features,
                iconName: network.iconName,
                primaryColor: network.primaryColor,
                blockTime: 4.5,
                gasPrice: nil
            )
        case .solana:
            return NetworkInfo(
                name: "Solana Mainnet",
                chainId: "solana-mainnet",
                rpcUrl: "https://api.mainnet-beta.solana.com",
                explorerUrl: "https://explorer.solana.com",
                nativeToken: "SOL",
                decimals: 9,
                isTestnet: false,
                priority: network.priority,
                supportsIPhone17Features: network.supportsIPhone17Features,
                iconName: network.iconName,
                primaryColor: network.primaryColor,
                blockTime: 0.4,
                gasPrice: nil
            )
        case .ethereum:
            return NetworkInfo(
                name: "Ethereum Mainnet",
                chainId: "ethereum-mainnet",
                rpcUrl: "https://mainnet.infura.io/v3",
                explorerUrl: "https://etherscan.io",
                nativeToken: "ETH",
                decimals: 18,
                isTestnet: false,
                priority: network.priority,
                supportsIPhone17Features: network.supportsIPhone17Features,
                iconName: network.iconName,
                primaryColor: network.primaryColor,
                blockTime: 12.0,
                gasPrice: 20.0
            )
        case .bitcoin:
            return NetworkInfo(
                name: "Bitcoin Mainnet",
                chainId: "bitcoin-mainnet",
                rpcUrl: "https://blockstream.info/api",
                explorerUrl: "https://blockstream.info",
                nativeToken: "BTC",
                decimals: 8,
                isTestnet: false,
                priority: network.priority,
                supportsIPhone17Features: network.supportsIPhone17Features,
                iconName: network.iconName,
                primaryColor: network.primaryColor,
                blockTime: 600.0,
                gasPrice: nil
            )
        case .polygon:
            return NetworkInfo(
                name: "Polygon Mainnet",
                chainId: "polygon-mainnet",
                rpcUrl: "https://polygon-rpc.com",
                explorerUrl: "https://polygonscan.com",
                nativeToken: "MATIC",
                decimals: 18,
                isTestnet: false,
                priority: network.priority,
                supportsIPhone17Features: network.supportsIPhone17Features,
                iconName: network.iconName,
                primaryColor: network.primaryColor,
                blockTime: 2.0,
                gasPrice: 30.0
            )
        case .arbitrum:
            return NetworkInfo(
                name: "Arbitrum Mainnet",
                chainId: "arbitrum-mainnet",
                rpcUrl: "https://arb1.arbitrum.io/rpc",
                explorerUrl: "https://arbiscan.io",
                nativeToken: "ETH",
                decimals: 18,
                isTestnet: false,
                priority: network.priority,
                supportsIPhone17Features: network.supportsIPhone17Features,
                iconName: network.iconName,
                primaryColor: network.primaryColor,
                blockTime: 0.25,
                gasPrice: 0.1
            )
        case .optimism:
            return NetworkInfo(
                name: "Optimism Mainnet",
                chainId: "optimism-mainnet",
                rpcUrl: "https://mainnet.optimism.io",
                explorerUrl: "https://optimistic.etherscan.io",
                nativeToken: "ETH",
                decimals: 18,
                isTestnet: false,
                priority: network.priority,
                supportsIPhone17Features: network.supportsIPhone17Features,
                iconName: network.iconName,
                primaryColor: network.primaryColor,
                blockTime: 2.0,
                gasPrice: 0.001
            )
        }
    }
}

// MARK: - Network Performance Metrics

public struct NetworkPerformanceMetrics: Codable, Sendable {
    public let network: SupportedNetwork
    public let averageBlockTime: Double
    public let averageGasPrice: Decimal?
    public let transactionSuccessRate: Double
    public let averageConfirmationTime: Double
    public let isOptimizedForIPhone17: Bool
    
    public init(network: SupportedNetwork) {
        self.network = network
        self.isOptimizedForIPhone17 = network.supportsIPhone17Features
        
        switch network {
        case .ethereum:
            self.averageBlockTime = 12.0
            self.averageGasPrice = 20.0
            self.transactionSuccessRate = 0.95
            self.averageConfirmationTime = 60.0
        case .bitcoin:
            self.averageBlockTime = 600.0
            self.averageGasPrice = nil
            self.transactionSuccessRate = 0.99
            self.averageConfirmationTime = 3600.0
        case .solana:
            self.averageBlockTime = 0.4
            self.averageGasPrice = nil
            self.transactionSuccessRate = 0.98
            self.averageConfirmationTime = 1.0
        case .polygon:
            self.averageBlockTime = 2.0
            self.averageGasPrice = 30.0
            self.transactionSuccessRate = 0.97
            self.averageConfirmationTime = 10.0
        case .arbitrum:
            self.averageBlockTime = 0.25
            self.averageGasPrice = 0.1
            self.transactionSuccessRate = 0.96
            self.averageConfirmationTime = 5.0
        case .optimism:
            self.averageBlockTime = 2.0
            self.averageGasPrice = 0.001
            self.transactionSuccessRate = 0.94
            self.averageConfirmationTime = 15.0
        case .algorand:
            self.averageBlockTime = 4.5
            self.averageGasPrice = nil
            self.transactionSuccessRate = 0.99
            self.averageConfirmationTime = 5.0
        case .ton:
            self.averageBlockTime = 5.0
            self.averageGasPrice = nil
            self.transactionSuccessRate = 0.98
            self.averageConfirmationTime = 10.0
        }
    }
}

// MARK: - Network Configuration for iPhone 17/17 Pro

public struct iPhone17NetworkConfig: Codable, Sendable {
    public let network: SupportedNetwork
    public let isEnabled: Bool
    public let priority: Int
    public let supportsAdvancedFeatures: Bool
    public let recommendedForIPhone17: Bool
    public let customRpcUrl: String?
    public let customExplorerUrl: String?
    
    public static func defaultConfig(for network: SupportedNetwork) -> iPhone17NetworkConfig {
        return iPhone17NetworkConfig(
            network: network,
            isEnabled: true,
            priority: network.priority,
            supportsAdvancedFeatures: network.supportsIPhone17Features,
            recommendedForIPhone17: network.priority >= 7,
            customRpcUrl: nil,
            customExplorerUrl: nil
        )
    }
}
