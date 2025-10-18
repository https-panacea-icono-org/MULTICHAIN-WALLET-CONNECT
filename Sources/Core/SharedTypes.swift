import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Supported Networks

public enum SupportedNetwork: String, CaseIterable, Codable {
    case ton = "ton"
    case algorand = "algorand"
    case solana = "solana"
    case ethereum = "ethereum"
    
    var displayName: String {
        switch self {
        case .ton: return "TON"
        case .algorand: return "Algorand"
        case .solana: return "Solana"
        case .ethereum: return "Ethereum"
        }
    }
    
    var chainId: String {
        switch self {
        case .ton: return "ton-mainnet"
        case .algorand: return "algorand-mainnet"
        case .solana: return "solana-mainnet"
        case .ethereum: return "ethereum-mainnet"
        }
    }
    
    var rpcUrl: String {
        switch self {
        case .ton: return "https://toncenter.com/api/v2"
        case .algorand: return "https://mainnet-api.algonode.cloud"
        case .solana: return "https://api.mainnet-beta.solana.com"
        case .ethereum: return "https://mainnet.infura.io/v3"
        }
    }
    
    var isMainnet: Bool {
        return true // Todas las redes están configuradas para mainnet
    }
}

// MARK: - Wallet Types

public enum WalletType: String, CaseIterable, Codable {
    case tonkeeper = "tonkeeper"
    case tonwallet = "tonwallet"
    case pera = "pera"
    case myalgo = "myalgo"
    case phantom = "phantom"
    case solflare = "solflare"
    case metamask = "metamask"
    case walletconnect = "walletconnect"
    
    var displayName: String {
        switch self {
        case .tonkeeper: return "TONKeeper"
        case .tonwallet: return "TonWallet"
        case .pera: return "Pera Wallet"
        case .myalgo: return "MyAlgo"
        case .phantom: return "Phantom"
        case .solflare: return "Solflare"
        case .metamask: return "MetaMask"
        case .walletconnect: return "WalletConnect"
        }
    }
    
    var iconName: String {
        switch self {
        case .tonkeeper: return "tonkeeper-icon"
        case .tonwallet: return "tonwallet-icon"
        case .pera: return "pera-icon"
        case .myalgo: return "myalgo-icon"
        case .phantom: return "phantom-icon"
        case .solflare: return "solflare-icon"
        case .metamask: return "metamask-icon"
        case .walletconnect: return "walletconnect-icon"
        }
    }
    
    var isInstalled: Bool {
        #if canImport(UIKit)
        switch self {
        case .tonkeeper:
            return UIApplication.shared.canOpenURL(URL(string: "tonkeeper://")!)
        case .tonwallet:
            return UIApplication.shared.canOpenURL(URL(string: "tonwallet://")!)
        case .pera:
            return UIApplication.shared.canOpenURL(URL(string: "algorand://")!)
        case .myalgo:
            return UIApplication.shared.canOpenURL(URL(string: "myalgo://")!)
        case .phantom:
            return UIApplication.shared.canOpenURL(URL(string: "phantom://")!)
        case .solflare:
            return UIApplication.shared.canOpenURL(URL(string: "solflare://")!)
        case .metamask:
            return UIApplication.shared.canOpenURL(URL(string: "metamask://")!)
        case .walletconnect:
            return true // WalletConnect es universal
        }
        #else
        return true // En macOS, asumimos que están disponibles
        #endif
    }
    
    var supportedNetworks: [SupportedNetwork] {
        switch self {
        case .tonkeeper, .tonwallet:
            return [.ton]
        case .pera, .myalgo:
            return [.algorand]
        case .phantom, .solflare:
            return [.solana]
        case .metamask, .walletconnect:
            return [.ethereum, .algorand, .solana, .ton]
        }
    }
}

// MARK: - Wallet Info

public struct WalletInfo: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let address: String
    public let network: SupportedNetwork
    public let walletType: WalletType
    public let isConnected: Bool
    public let balance: Decimal?
    public let lastConnected: Date?
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        address: String,
        network: SupportedNetwork,
        walletType: WalletType,
        isConnected: Bool = false,
        balance: Decimal? = nil,
        lastConnected: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.network = network
        self.walletType = walletType
        self.isConnected = isConnected
        self.balance = balance
        self.lastConnected = lastConnected
    }
}

// MARK: - Network Info

public struct NetworkInfo: Codable {
    public let name: String
    public let chainId: String
    public let rpcUrl: String
    public let explorerUrl: String
    public let nativeToken: String
    public let decimals: Int
    public let isTestnet: Bool
    
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
                isTestnet: false
            )
        case .algorand:
            return NetworkInfo(
                name: "Algorand Mainnet",
                chainId: "algorand-mainnet",
                rpcUrl: "https://mainnet-api.algonode.cloud",
                explorerUrl: "https://algoexplorer.io",
                nativeToken: "ALGO",
                decimals: 6,
                isTestnet: false
            )
        case .solana:
            return NetworkInfo(
                name: "Solana Mainnet",
                chainId: "solana-mainnet",
                rpcUrl: "https://api.mainnet-beta.solana.com",
                explorerUrl: "https://explorer.solana.com",
                nativeToken: "SOL",
                decimals: 9,
                isTestnet: false
            )
        case .ethereum:
            return NetworkInfo(
                name: "Ethereum Mainnet",
                chainId: "ethereum-mainnet",
                rpcUrl: "https://mainnet.infura.io/v3",
                explorerUrl: "https://etherscan.io",
                nativeToken: "ETH",
                decimals: 18,
                isTestnet: false
            )
        }
    }
}

// MARK: - Transaction Request

public struct TransactionRequest: Codable {
    public let to: String
    public let amount: Decimal
    public let token: String?
    public let note: String?
    public let from: String
    public let gasLimit: UInt64?
    public let gasPrice: Decimal?
    
    public init(
        to: String,
        amount: Decimal,
        token: String? = nil,
        note: String? = nil,
        from: String,
        gasLimit: UInt64? = nil,
        gasPrice: Decimal? = nil
    ) {
        self.to = to
        self.amount = amount
        self.token = token
        self.note = note
        self.from = from
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
    }
}

// MARK: - Wallet Connection Data

public struct WalletConnectionData: Codable {
    public let walletType: WalletType
    public let network: SupportedNetwork
    public let timestamp: Date
    public let sessionId: String
    public let deepLink: String?
    
    public init(
        walletType: WalletType,
        network: SupportedNetwork,
        timestamp: Date,
        sessionId: String,
        deepLink: String? = nil
    ) {
        self.walletType = walletType
        self.network = network
        self.timestamp = timestamp
        self.sessionId = sessionId
        self.deepLink = deepLink
    }
}

// MARK: - Network Manager Protocol

public protocol NetworkManagerProtocol {
    func connectWallet(_ walletType: WalletType) async throws -> WalletInfo
    func disconnectWallet(_ walletInfo: WalletInfo) async
    func sendTransaction(_ transaction: TransactionRequest) async throws -> String
    func getBalance(address: String, token: String?) async throws -> Decimal
    func getAvailableWallets() -> [WalletInfo]
}

// MARK: - QR Code Manager

public class QRCodeManager {
    
    public init() {}
    
    public func generateQRCode(for data: WalletConnectionData) async throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
        
        // Aquí implementarías la generación del QR usando una librería como CoreImage
        // Por ahora retornamos el JSON string
        return jsonString
    }
    
    public func parseQRCode(_ qrString: String) throws -> WalletConnectionData {
        guard let data = qrString.data(using: .utf8) else {
            throw WalletError.invalidQRCode
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(WalletConnectionData.self, from: data)
    }
}

// MARK: - WalletConnect Manager

public class WalletConnectManager {
    
    public init() {}
    
    public func initialize() async throws {
        // Implementar inicialización de WalletConnect
    }
    
    public func connectToWallet(_ walletType: WalletType) async throws -> WalletInfo {
        // Implementar conexión via WalletConnect
        throw WalletError.connectionFailed
    }
}

// MARK: - Wallet Errors

public enum WalletError: LocalizedError {
    case unsupportedNetwork
    case noWalletConnected
    case connectionFailed
    case invalidQRCode
    case walletNotInstalled
    case transactionFailed
    
    public var errorDescription: String? {
        switch self {
        case .unsupportedNetwork:
            return "Red no soportada"
        case .noWalletConnected:
            return "No hay billetera conectada"
        case .connectionFailed:
            return "Error al conectar billetera"
        case .invalidQRCode:
            return "Código QR inválido"
        case .walletNotInstalled:
            return "Billetera no instalada"
        case .transactionFailed:
            return "Error al enviar transacción"
        }
    }
}
