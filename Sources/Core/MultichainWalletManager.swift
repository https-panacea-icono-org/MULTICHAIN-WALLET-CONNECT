import Foundation
import Combine
import SwiftUI

// Importar tipos compartidos
// Los tipos están definidos en SharedTypes.swift

/// Gestor principal para conexión multichain de billeteras
@MainActor
public class MultichainWalletManager: ObservableObject {
    
    // MARK: - Singleton
    public static let shared = MultichainWalletManager()
    
    // MARK: - Published Properties
    @Published public var isConnected: Bool = false
    @Published public var currentWallet: WalletInfo?
    @Published public var currentNetwork: SupportedNetwork?
    @Published public var connectionStatus: ConnectionStatus = .disconnected
    @Published public var availableWallets: [WalletInfo] = []
    
    // MARK: - Private Properties
    private var networkManagers: [SupportedNetwork: NetworkManagerProtocol] = [:]
    private var cancellables = Set<AnyCancellable>()
    private let qrCodeManager = QRCodeManager()
    private let walletConnectManager = WalletConnectManager()
    
    // MARK: - Initialization
    private init() {
        setupNetworkManagers()
        setupObservers()
    }
    
    // MARK: - Public Methods
    
    /// Conectar a una billetera específica
    public func connectWallet(_ walletType: WalletType, network: SupportedNetwork? = nil) async throws {
        let targetNetwork = network ?? getDefaultNetwork(for: walletType)
        
        guard let networkManager = networkManagers[targetNetwork] else {
            throw WalletError.unsupportedNetwork
        }
        
        connectionStatus = .connecting
        
        do {
            let walletInfo = try await networkManager.connectWallet(walletType)
            currentWallet = walletInfo
            currentNetwork = targetNetwork
            isConnected = true
            connectionStatus = .connected
            
            // Notificar cambio de estado
            objectWillChange.send()
            
        } catch {
            connectionStatus = .failed
            throw error
        }
    }
    
    /// Desconectar billetera actual
    public func disconnectWallet() async {
        guard let currentWallet = currentWallet,
              let currentNetwork = currentNetwork,
              let networkManager = networkManagers[currentNetwork] else {
            return
        }
        
        await networkManager.disconnectWallet(currentWallet)
        
        self.currentWallet = nil
        self.currentNetwork = nil
        isConnected = false
        connectionStatus = .disconnected
        
        objectWillChange.send()
    }
    
    /// Generar QR para conexión
    public func generateConnectionQR(for walletType: WalletType, network: SupportedNetwork? = nil) async throws -> String {
        let targetNetwork = network ?? getDefaultNetwork(for: walletType)
        
        let connectionData = WalletConnectionData(
            walletType: walletType,
            network: targetNetwork,
            timestamp: Date(),
            sessionId: UUID().uuidString
        )
        
        return try await qrCodeManager.generateQRCode(for: connectionData)
    }
    
    /// Escanear QR y conectar
    public func scanAndConnect(qrCode: String) async throws {
        let connectionData = try qrCodeManager.parseQRCode(qrCode)
        
        try await connectWallet(
            connectionData.walletType,
            network: connectionData.network
        )
    }
    
    /// Obtener billeteras disponibles para una red
    public func getAvailableWallets(for network: SupportedNetwork) -> [WalletInfo] {
        return networkManagers[network]?.getAvailableWallets() ?? []
    }
    
    /// Enviar transacción
    public func sendTransaction(
        to address: String,
        amount: Decimal,
        token: String? = nil,
        note: String? = nil
    ) async throws -> String {
        guard let currentWallet = currentWallet,
              let currentNetwork = currentNetwork,
              let networkManager = networkManagers[currentNetwork] else {
            throw WalletError.noWalletConnected
        }
        
        let transaction = TransactionRequest(
            to: address,
            amount: amount,
            token: token,
            note: note,
            from: currentWallet.address
        )
        
        return try await networkManager.sendTransaction(transaction)
    }
    
    /// Obtener balance
    public func getBalance(token: String? = nil) async throws -> Decimal {
        guard let currentWallet = currentWallet,
              let currentNetwork = currentNetwork,
              let networkManager = networkManagers[currentNetwork] else {
            throw WalletError.noWalletConnected
        }
        
        return try await networkManager.getBalance(
            address: currentWallet.address,
            token: token
        )
    }
    
    /// Verificar si una billetera está instalada
    public func isWalletInstalled(_ walletType: WalletType) -> Bool {
        return walletType.isInstalled
    }
    
    /// Obtener información de la red actual
    public func getCurrentNetworkInfo() -> NetworkInfo? {
        guard let currentNetwork = currentNetwork else { return nil }
        return NetworkInfo.from(network: currentNetwork)
    }
    
    // MARK: - Private Methods
    
    private func setupNetworkManagers() {
        // TON Network Manager
        networkManagers[.ton] = TONNetworkManager()
        
        // Algorand Network Manager
        networkManagers[.algorand] = AlgorandNetworkManager()
        
        // Solana Network Manager
        networkManagers[.solana] = SolanaNetworkManager()
        
        // Ethereum Network Manager
        networkManagers[.ethereum] = EthereumNetworkManager()
    }
    
    private func setupObservers() {
        // Observar cambios en el estado de conexión
        $isConnected
            .sink { [weak self] isConnected in
                self?.updateAvailableWallets()
            }
            .store(in: &cancellables)
    }
    
    private func updateAvailableWallets() {
        var wallets: [WalletInfo] = []
        
        for (network, manager) in networkManagers {
            let networkWallets = manager.getAvailableWallets()
            wallets.append(contentsOf: networkWallets)
        }
        
        availableWallets = wallets
    }
    
    private func getDefaultNetwork(for walletType: WalletType) -> SupportedNetwork {
        switch walletType {
        case .tonkeeper, .tonwallet:
            return .ton
        case .pera, .myalgo:
            return .algorand
        case .phantom, .solflare:
            return .solana
        case .metamask, .walletconnect:
            return .ethereum
        }
    }
}

// MARK: - Supporting Types

public enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    case failed
    
    var displayName: String {
        switch self {
        case .disconnected: return "Desconectado"
        case .connecting: return "Conectando..."
        case .connected: return "Conectado"
        case .failed: return "Error de conexión"
        }
    }
}

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
