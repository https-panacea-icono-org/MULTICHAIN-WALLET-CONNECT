import Foundation

/// Configuración de WalletConnect para el ecosistema PANACEA
public struct WalletConnectConfig {
    
    // MARK: - WalletConnect IDs
    public static let projectId = "1ceaca1be9a50ff20c416f4b7da95d84"
    public static let sessionId = "c05e44f7-8a6e-45ef-be63-438fee9d8676"
    
    // MARK: - Configuración de la aplicación
    public static let appName = "PANACEA Ecosystem"
    public static let appVersion = "1.0.0"
    public static let apiBaseUrl = "https://api.panacea-icono.org"
    public static let isProduction = true
    
    // MARK: - Redes soportadas (Mainnet)
    public static let supportedNetworks: [SupportedNetwork] = [.ton, .algorand, .solana, .ethereum]
    public static let defaultNetwork: SupportedNetwork = .algorand
    public static let networkType = "mainnet"
    
    // MARK: - URLs de RPC para Mainnet
    public static let tonRpcUrl = "https://toncenter.com/api/v2"
    public static let algorandRpcUrl = "https://mainnet-api.algonode.cloud"
    public static let solanaRpcUrl = "https://api.mainnet-beta.solana.com"
    public static let ethereumRpcUrl = "https://mainnet.infura.io/v3"
    
    // MARK: - URLs de exploradores
    public static let tonExplorerUrl = "https://tonscan.org"
    public static let algorandExplorerUrl = "https://algoexplorer.io"
    public static let solanaExplorerUrl = "https://explorer.solana.com"
    public static let ethereumExplorerUrl = "https://etherscan.io"
    
    // MARK: - Configuración de WalletConnect
    public static let walletConnectBridge = "https://bridge.walletconnect.org"
    public static let walletConnectRelay = "wss://relay.walletconnect.org"
    
    // MARK: - Métodos de utilidad
    
    /// Obtener URL de RPC para una red específica
    public static func getRpcUrl(for network: SupportedNetwork) -> String {
        switch network {
        case .ton: return tonRpcUrl
        case .algorand: return algorandRpcUrl
        case .solana: return solanaRpcUrl
        case .ethereum: return ethereumRpcUrl
        }
    }
    
    /// Obtener URL de explorador para una red específica
    public static func getExplorerUrl(for network: SupportedNetwork) -> String {
        switch network {
        case .ton: return tonExplorerUrl
        case .algorand: return algorandExplorerUrl
        case .solana: return solanaExplorerUrl
        case .ethereum: return ethereumExplorerUrl
        }
    }
    
    /// Verificar si una red está soportada
    public static func isNetworkSupported(_ network: SupportedNetwork) -> Bool {
        return supportedNetworks.contains(network)
    }
    
    /// Obtener configuración de WalletConnect
    public static func getWalletConnectConfig() -> (projectId: String, sessionId: String, bridge: String, relay: String) {
        return (
            projectId: projectId,
            sessionId: sessionId,
            bridge: walletConnectBridge,
            relay: walletConnectRelay
        )
    }
}

// MARK: - Configuración de entorno

public enum Environment {
    case development
    case staging
    case production
    
    var isProduction: Bool {
        return self == .production
    }
    
    var apiBaseUrl: String {
        switch self {
        case .development:
            return "https://dev-api.panacea-icono.org"
        case .staging:
            return "https://staging-api.panacea-icono.org"
        case .production:
            return "https://api.panacea-icono.org"
        }
    }
}

// MARK: - Configuración de red

public struct NetworkConfig {
    public let name: String
    public let chainId: String
    public let rpcUrl: String
    public let explorerUrl: String
    public let nativeToken: String
    public let decimals: Int
    public let isMainnet: Bool
    
    public init(
        name: String,
        chainId: String,
        rpcUrl: String,
        explorerUrl: String,
        nativeToken: String,
        decimals: Int,
        isMainnet: Bool = true
    ) {
        self.name = name
        self.chainId = chainId
        self.rpcUrl = rpcUrl
        self.explorerUrl = explorerUrl
        self.nativeToken = nativeToken
        self.decimals = decimals
        self.isMainnet = isMainnet
    }
    
    /// Obtener configuración de red para una red específica
    public static func forNetwork(_ network: SupportedNetwork) -> NetworkConfig {
        switch network {
        case .ton:
            return NetworkConfig(
                name: "TON Mainnet",
                chainId: "ton-mainnet",
                rpcUrl: WalletConnectConfig.tonRpcUrl,
                explorerUrl: WalletConnectConfig.tonExplorerUrl,
                nativeToken: "TON",
                decimals: 9,
                isMainnet: true
            )
        case .algorand:
            return NetworkConfig(
                name: "Algorand Mainnet",
                chainId: "algorand-mainnet",
                rpcUrl: WalletConnectConfig.algorandRpcUrl,
                explorerUrl: WalletConnectConfig.algorandExplorerUrl,
                nativeToken: "ALGO",
                decimals: 6,
                isMainnet: true
            )
        case .solana:
            return NetworkConfig(
                name: "Solana Mainnet",
                chainId: "solana-mainnet",
                rpcUrl: WalletConnectConfig.solanaRpcUrl,
                explorerUrl: WalletConnectConfig.solanaExplorerUrl,
                nativeToken: "SOL",
                decimals: 9,
                isMainnet: true
            )
        case .ethereum:
            return NetworkConfig(
                name: "Ethereum Mainnet",
                chainId: "ethereum-mainnet",
                rpcUrl: WalletConnectConfig.ethereumRpcUrl,
                explorerUrl: WalletConnectConfig.ethereumExplorerUrl,
                nativeToken: "ETH",
                decimals: 18,
                isMainnet: true
            )
        }
    }
}
