// MARK: - Multichain Wallet Manager
// This file contains the main wallet manager that coordinates all network managers

import Foundation
import Combine
import SwiftUI

// MARK: - Multichain Wallet Manager

@MainActor
public class MultichainWalletManager: ObservableObject, WalletManagerProtocol {
    
    // MARK: - Properties
    public static let shared = MultichainWalletManager()
    
    @Published public var connectedWallets: [WalletInfo] = []
    @Published public var availableWallets: [WalletInfo] = []
    @Published public var isConnecting: Bool = false
    
    private var networkManagers: [SupportedNetwork: NetworkManagerProtocol] = [:]
    private let queue = DispatchQueue(label: "multichain.wallet.manager", attributes: .concurrent)
    
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
