// MARK: - Mock Network Manager Implementation
// This file contains mock implementations for testing and demo purposes

import Foundation

// Mock implementation for demo and testing purposes.
// Simulates wallet connections, balances, and transaction sending per network.

final class MockNetworkManager: NetworkManagerProtocol, @unchecked Sendable {

    private let network: SupportedNetwork
    private var connected: [String: WalletInfo] = [:] // key: address
    private let queue = DispatchQueue(label: "mock.network.manager", attributes: .concurrent)

    init(network: SupportedNetwork) {
        self.network = network
    }

    func connectWallet(_ walletType: WalletType) async throws -> WalletInfo {
        // Simulate a connection delay.
        try await Task.sleep(nanoseconds: 200_000_000)

        // Generate a deterministic mock address per network + wallet type for demo.
        let address = mockAddress(for: walletType, network: network)
        let info = WalletInfo(
            name: walletType.displayName,
            address: address,
            network: network,
            walletType: walletType,
            isConnected: true,
            balance: mockInitialBalance(for: network),
            lastConnected: Date()
        )
        
        await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                self.connected[address] = info
                continuation.resume()
            }
        }
        
        return info
    }

    func disconnectWallet(_ walletInfo: WalletInfo) async {
        await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                self.connected.removeValue(forKey: walletInfo.address)
                continuation.resume()
            }
        }
    }

    func sendTransaction(_ transaction: TransactionRequest) async throws -> String {
        // Ensure the sender is connected on this manager's network.
        let isConnected = await withCheckedContinuation { continuation in
            queue.async {
                let connected = self.connected[transaction.from] != nil
                continuation.resume(returning: connected)
            }
        }
        
        guard isConnected else {
            throw WalletError.noWalletConnected
        }
        
        // Simulate network latency.
        try await Task.sleep(nanoseconds: 150_000_000)

        // Return a mock transaction hash.
        return mockTransactionHash(for: network)
    }

    func getBalance(address: String, token: String?) async throws -> Decimal {
        // Simulate network latency.
        try await Task.sleep(nanoseconds: 100_000_000)

        // If the address is "connected", return a slightly different balance.
        let isConnected = await withCheckedContinuation { continuation in
            queue.async {
                let connected = self.connected[address] != nil
                continuation.resume(returning: connected)
            }
        }
        
        if isConnected {
            return mockConnectedBalance(for: network, token: token)
        } else {
            return mockInitialBalance(for: network)
        }
    }

    func getAvailableWallets() -> [WalletInfo] {
        // Expose available wallets for this network based on WalletType.supportedNetworks.
        let supported = WalletType.allCases.filter { $0.supportedNetworks.contains(network) }
        return supported.map { walletType in
            let address = mockAddress(for: walletType, network: network)
            let isConnected = queue.sync { connected[address] != nil }
            
            return WalletInfo(
                name: walletType.displayName,
                address: address,
                network: network,
                walletType: walletType,
                isConnected: isConnected,
                balance: mockInitialBalance(for: network),
                lastConnected: nil
            )
        }
    }
}

// MARK: - Mock helpers

private extension MockNetworkManager {
    func mockAddress(for walletType: WalletType, network: SupportedNetwork) -> String {
        // Simple deterministic address per network for demo purposes.
        switch network {
        case .ton:
            return "UQ" + String(walletType.rawValue.prefix(6)).uppercased() + "MOCKTONADDR"
        case .algorand:
            return "ALGO" + String(walletType.rawValue.prefix(6)).uppercased() + "MOCKADDR"
        case .solana:
            return "So" + String(walletType.rawValue.prefix(6)).uppercased() + "MockSolAddr"
        case .ethereum:
            return "0x" + String(walletType.rawValue.prefix(8)).padding(toLength: 40, withPad: "a", startingAt: 0)
        case .bitcoin:
            return "bc1" + String(walletType.rawValue.prefix(6)).uppercased() + "MockBtcAddr"
        case .polygon:
            return "0x" + String(walletType.rawValue.prefix(8)).padding(toLength: 40, withPad: "b", startingAt: 0)
        case .arbitrum:
            return "0x" + String(walletType.rawValue.prefix(8)).padding(toLength: 40, withPad: "c", startingAt: 0)
        case .optimism:
            return "0x" + String(walletType.rawValue.prefix(8)).padding(toLength: 40, withPad: "d", startingAt: 0)
        }
    }

    func mockInitialBalance(for network: SupportedNetwork) -> Decimal {
        switch network {
        case .ton: return 10.0
        case .algorand: return 25.5
        case .solana: return 5.123
        case .ethereum: return 0.75
        case .bitcoin: return 0.001
        case .polygon: return 100.0
        case .arbitrum: return 0.5
        case .optimism: return 0.3
        }
    }

    func mockConnectedBalance(for network: SupportedNetwork, token: String?) -> Decimal {
        // Add a small delta to show "updated" balance.
        let base = mockInitialBalance(for: network)
        return base + (token == nil ? 0.001 : 1.0)
    }

    func mockTransactionHash(for network: SupportedNetwork) -> String {
        switch network {
        case .ton: return "ton_tx_" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        case .algorand: return "algo_tx_" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        case .solana: return "sol_tx_" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        case .ethereum: return "0x" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        case .bitcoin: return "btc_tx_" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        case .polygon: return "0x" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        case .arbitrum: return "0x" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        case .optimism: return "0x" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        }
    }
}

// MARK: - Mock Network Manager Factory

public class MockNetworkManagerFactory {
    public static func createManagers(for networks: [SupportedNetwork]) -> [SupportedNetwork: NetworkManagerProtocol] {
        var managers: [SupportedNetwork: NetworkManagerProtocol] = [:]
        
        for network in networks {
            let manager = MockNetworkManager(network: network)
            managers[network] = manager
        }
        
        return managers
    }
}
