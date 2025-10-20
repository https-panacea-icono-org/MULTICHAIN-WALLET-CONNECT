// MARK: - Configuration Management
// This file handles configuration for WalletConnect and network settings

import Foundation

// MARK: - Configuration Protocol

public protocol ConfigurationProvider: Sendable {
    var walletConnectProjectId: String { get }
    var walletConnectSessionId: String { get }
    var ethereumInfuraProjectId: String? { get }
    var tonCenterApiKey: String? { get }
    var isDebugMode: Bool { get }
}

// MARK: - Default Configuration

public struct DefaultConfiguration: ConfigurationProvider {
    public let walletConnectProjectId: String
    public let walletConnectSessionId: String
    public let ethereumInfuraProjectId: String?
    public let tonCenterApiKey: String?
    public let isDebugMode: Bool
    
    public init(
        walletConnectProjectId: String = "1ceaca1be9a50ff20c416f4b7da95d84",
        walletConnectSessionId: String = "c05e44f7-8a6e-45ef-be63-438fee9d8676",
        ethereumInfuraProjectId: String? = nil,
        tonCenterApiKey: String? = nil,
        isDebugMode: Bool = false
    ) {
        self.walletConnectProjectId = walletConnectProjectId
        self.walletConnectSessionId = walletConnectSessionId
        self.ethereumInfuraProjectId = ethereumInfuraProjectId
        self.tonCenterApiKey = tonCenterApiKey
        self.isDebugMode = isDebugMode
    }
}

// MARK: - Environment Configuration

public struct EnvironmentConfiguration: ConfigurationProvider {
    public let walletConnectProjectId: String
    public let walletConnectSessionId: String
    public let ethereumInfuraProjectId: String?
    public let tonCenterApiKey: String?
    public let isDebugMode: Bool
    
    public init() {
        let env = ProcessInfo.processInfo.environment
        
        self.walletConnectProjectId = env["WALLETCONNECT_PROJECT_ID"] ?? "1ceaca1be9a50ff20c416f4b7da95d84"
        self.walletConnectSessionId = env["WALLETCONNECT_SESSION_ID"] ?? "c05e44f7-8a6e-45ef-be63-438fee9d8676"
        self.ethereumInfuraProjectId = env["ETHEREUM_INFURA_PROJECT_ID"]
        self.tonCenterApiKey = env["TONCENTER_API_KEY"]
        self.isDebugMode = env["DEBUG_MODE"] == "true"
    }
}

// MARK: - Configuration Manager

public class ConfigurationManager: @unchecked Sendable {
    public static let shared = ConfigurationManager()
    
    private var _configuration: ConfigurationProvider?
    private let queue = DispatchQueue(label: "configuration.manager", attributes: .concurrent)
    
    public var configuration: ConfigurationProvider {
        return queue.sync {
            if let config = _configuration {
                return config
            }
            
            // Intentar cargar desde variables de entorno primero
            let envConfig = EnvironmentConfiguration()
            _configuration = envConfig
            return envConfig
        }
    }
    
    public func setConfiguration(_ configuration: ConfigurationProvider) {
        queue.async(flags: .barrier) {
            self._configuration = configuration
        }
    }
    
    public func resetToDefault() {
        queue.async(flags: .barrier) {
            self._configuration = nil
        }
    }
    
    private init() {}
}

// MARK: - Network Configuration

public struct NetworkConfiguration: Codable, Sendable {
    public let rpcUrl: String
    public let chainId: String
    public let isMainnet: Bool
    public let explorerUrl: String
    public let nativeToken: String
    public let decimals: Int
    
    public init(
        rpcUrl: String,
        chainId: String,
        isMainnet: Bool,
        explorerUrl: String,
        nativeToken: String,
        decimals: Int
    ) {
        self.rpcUrl = rpcUrl
        self.chainId = chainId
        self.isMainnet = isMainnet
        self.explorerUrl = explorerUrl
        self.nativeToken = nativeToken
        self.decimals = decimals
    }
}

// MARK: - Network Configuration Factory

public class NetworkConfigurationFactory {
    public static func createConfiguration(for network: SupportedNetwork, config: ConfigurationProvider) -> NetworkConfiguration {
        switch network {
        case .ton:
            return NetworkConfiguration(
                rpcUrl: "https://toncenter.com/api/v2",
                chainId: "ton-mainnet",
                isMainnet: true,
                explorerUrl: "https://tonscan.org",
                nativeToken: "TON",
                decimals: 9
            )
            
        case .algorand:
            return NetworkConfiguration(
                rpcUrl: "https://mainnet-api.algonode.cloud",
                chainId: "algorand-mainnet",
                isMainnet: true,
                explorerUrl: "https://algoexplorer.io",
                nativeToken: "ALGO",
                decimals: 6
            )
            
        case .solana:
            return NetworkConfiguration(
                rpcUrl: "https://api.mainnet-beta.solana.com",
                chainId: "solana-mainnet",
                isMainnet: true,
                explorerUrl: "https://explorer.solana.com",
                nativeToken: "SOL",
                decimals: 9
            )
            
        case .ethereum:
            let rpcUrl: String
            if let infuraProjectId = config.ethereumInfuraProjectId {
                rpcUrl = "https://mainnet.infura.io/v3/\(infuraProjectId)"
            } else {
                rpcUrl = "https://mainnet.infura.io/v3"
            }
            
            return NetworkConfiguration(
                rpcUrl: rpcUrl,
                chainId: "ethereum-mainnet",
                isMainnet: true,
                explorerUrl: "https://etherscan.io",
                nativeToken: "ETH",
                decimals: 18
            )
            
        case .bitcoin:
            return NetworkConfiguration(
                rpcUrl: "https://blockstream.info/api",
                chainId: "bitcoin-mainnet",
                isMainnet: true,
                explorerUrl: "https://blockstream.info",
                nativeToken: "BTC",
                decimals: 8
            )
            
        case .polygon:
            return NetworkConfiguration(
                rpcUrl: "https://polygon-rpc.com",
                chainId: "polygon-mainnet",
                isMainnet: true,
                explorerUrl: "https://polygonscan.com",
                nativeToken: "MATIC",
                decimals: 18
            )
            
        case .arbitrum:
            return NetworkConfiguration(
                rpcUrl: "https://arb1.arbitrum.io/rpc",
                chainId: "arbitrum-mainnet",
                isMainnet: true,
                explorerUrl: "https://arbiscan.io",
                nativeToken: "ETH",
                decimals: 18
            )
            
        case .optimism:
            return NetworkConfiguration(
                rpcUrl: "https://mainnet.optimism.io",
                chainId: "optimism-mainnet",
                isMainnet: true,
                explorerUrl: "https://optimistic.etherscan.io",
                nativeToken: "ETH",
                decimals: 18
            )
        }
    }
}

// MARK: - WalletConnect Configuration

public struct WalletConnectConfig {
    public static let projectId: String = "1ceaca1be9a50ff20c416f4b7da95d84"
    public static let sessionId: String = "c05e44f7-8a6e-45ef-be63-438fee9d8676"
    public static let bridgeUrl: String = "https://bridge.walletconnect.org"
    public static let relayUrl: String = "wss://relay.walletconnect.org"
}
