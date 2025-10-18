// MARK: - MultichainWalletConnect Module Entry Point

import Foundation
import Combine
import SwiftUI

// MARK: - Supported Networks

public enum SupportedNetwork: String, CaseIterable, Codable {
    case ton = "ton"
    case algorand = "algorand"
    case solana = "solana"
    case ethereum = "ethereum"
    
    public var displayName: String {
        switch self {
        case .ton: return "TON"
        case .algorand: return "Algorand"
        case .solana: return "Solana"
        case .ethereum: return "Ethereum"
        }
    }
    
    public var chainId: String {
        switch self {
        case .ton: return "ton-mainnet"
        case .algorand: return "algorand-mainnet"
        case .solana: return "solana-mainnet"
        case .ethereum: return "ethereum-mainnet"
        }
    }
    
    public var rpcUrl: String {
        switch self {
        case .ton: return "https://toncenter.com/api/v2"
        case .algorand: return "https://mainnet-api.algonode.cloud"
        case .solana: return "https://api.mainnet-beta.solana.com"
        case .ethereum: return "https://mainnet.infura.io/v3"
        }
    }
    
    public var isMainnet: Bool {
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
    
    public var displayName: String {
        switch self {
        case .tonkeeper: return "TONKeeper"
        case .tonwallet: return "TON Wallet"
        case .pera: return "Pera Wallet"
        case .myalgo: return "MyAlgo"
        case .phantom: return "Phantom"
        case .solflare: return "Solflare"
        case .metamask: return "MetaMask"
        case .walletconnect: return "WalletConnect"
        }
    }
    
    public var iconName: String {
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
    
    public var isInstalled: Bool {
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
    
    public var supportedNetworks: [SupportedNetwork] {
        switch self {
        case .tonkeeper, .tonwallet:
            return [.ton]
        case .pera, .myalgo:
            return [.algorand]
        case .phantom, .solflare:
            return [.solana]
        case .metamask:
            return [.ethereum]
        case .walletconnect:
            return SupportedNetwork.allCases // WalletConnect soporta todas
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

// MARK: - Wallet Error

public enum WalletError: LocalizedError {
    case unsupportedNetwork
    case noWalletConnected
    case connectionFailed
    case invalidQRCode
    case walletNotInstalled
    case transactionFailed
    case signingFailed
    case invalidResponse
    case invalidConfiguration
    case custom(String)
    
    public var errorDescription: String? {
        switch self {
        case .unsupportedNetwork: return "La red seleccionada no está soportada."
        case .noWalletConnected: return "No hay una billetera conectada."
        case .connectionFailed: return "Fallo la conexión con la billetera."
        case .invalidQRCode: return "Código QR inválido."
        case .walletNotInstalled: return "La billetera no está instalada en este dispositivo."
        case .transactionFailed: return "Fallo el envío de la transacción."
        case .signingFailed: return "Fallo la firma de la transacción."
        case .invalidResponse: return "Respuesta inválida de la billetera o red."
        case .invalidConfiguration: return "Configuración inválida del servicio."
        case .custom(let message): return message
        }
    }
}

// MARK: - Multichain Wallet Manager

@MainActor
public class MultichainWalletManager: ObservableObject {
    
    // MARK: - Properties
    public static let shared = MultichainWalletManager()
    
    @Published public var connectedWallets: [WalletInfo] = []
    @Published public var availableWallets: [WalletInfo] = []
    @Published public var isConnecting: Bool = false
    
    private var networkManagers: [SupportedNetwork: NetworkManagerProtocol] = [:]
    
    // MARK: - Initialization
    
    private init() {
        setupNetworkManagers()
        updateAvailableWallets()
    }
    
    // MARK: - Public Methods
    
    public func connectWallet(_ walletType: WalletType, network: SupportedNetwork? = nil) async throws -> WalletInfo {
        isConnecting = true
        defer { isConnecting = false }
        
        let targetNetwork = network ?? getDefaultNetwork(for: walletType)
        
        guard let manager = networkManagers[targetNetwork] else {
            throw WalletError.unsupportedNetwork
        }
        
        let walletInfo = try await manager.connectWallet(walletType)
        
        // Agregar a la lista de billeteras conectadas
        if !connectedWallets.contains(where: { $0.id == walletInfo.id }) {
            connectedWallets.append(walletInfo)
        }
        
        return walletInfo
    }
    
    public func disconnectWallet(_ walletInfo: WalletInfo) async {
        guard let manager = networkManagers[walletInfo.network] else { return }
        
        await manager.disconnectWallet(walletInfo)
        
        // Remover de la lista de billeteras conectadas
        connectedWallets.removeAll { $0.id == walletInfo.id }
    }
    
    public func sendTransaction(_ transaction: TransactionRequest) async throws -> String {
        guard let walletInfo = connectedWallets.first(where: { $0.address == transaction.from }) else {
            throw WalletError.noWalletConnected
        }
        
        guard let manager = networkManagers[walletInfo.network] else {
            throw WalletError.unsupportedNetwork
        }
        
        return try await manager.sendTransaction(transaction)
    }
    
    public func getBalance(for address: String, network: SupportedNetwork, token: String? = nil) async throws -> Decimal {
        guard let manager = networkManagers[network] else {
            throw WalletError.unsupportedNetwork
        }
        
        return try await manager.getBalance(address: address, token: token)
    }
    
    public func getAvailableWallets(for network: SupportedNetwork? = nil) -> [WalletInfo] {
        if let network = network {
            return networkManagers[network]?.getAvailableWallets() ?? []
        }
        
        return availableWallets
    }
    
    // MARK: - Private Methods
    
    private func setupNetworkManagers() {
        // Register mock managers for all networks to provide a working demo.
        networkManagers = MockNetworkManagerFactory.createManagers(for: Array(SupportedNetwork.allCases))
    }
    
    private func updateAvailableWallets() {
        var wallets: [WalletInfo] = []
        
        for (_, manager) in networkManagers {
            let networkWallets = manager.getAvailableWallets()
            wallets.append(contentsOf: networkWallets)
        }
        
        availableWallets = wallets
    }
    
    private func getDefaultNetwork(for walletType: WalletType) -> SupportedNetwork {
        return walletType.supportedNetworks.first ?? .algorand
    }
}

// MARK: - WalletConnect Configuration

public struct WalletConnectConfig {
    public static let projectId: String = "1ceaca1be9a50ff20c416f4b7da95d84"
    public static let sessionId: String = "c05e44f7-8a6e-45ef-be63-438fee9d8676"
}

// MARK: - QR Code Generator

public class QRCodeGenerator {
    
    private let context = CIContext()
    
    public init() {}
    
    public func generateQRCode(from string: String, size: CGSize = CGSize(width: 300, height: 300)) async throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw WalletError.invalidQRCode
        }
        
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            throw WalletError.invalidConfiguration
        }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let ciImage = qrFilter.outputImage else {
            throw WalletError.invalidConfiguration
        }
        
        let scaleX = size.width / ciImage.extent.size.width
        let scaleY = size.height / ciImage.extent.size.height
        let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        #if canImport(UIKit)
        if let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) {
            return UIImage(cgImage: cgImage).toBase64() ?? ""
        }
        #endif
        throw WalletError.invalidConfiguration
    }
    
    public func generateConnectionQR(for walletType: WalletType, network: SupportedNetwork) async throws -> String {
        let connectionData = WalletConnectionData(
            walletType: walletType,
            network: network,
            timestamp: Date(),
            sessionId: UUID().uuidString
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(connectionData)
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        
        return try await generateQRCode(from: jsonString)
    }
}

#if canImport(UIKit)
extension UIImage {
    func toBase64() -> String? {
        return self.jpegData(compressionQuality: 1.0)?.base64EncodedString()
    }
}
#endif