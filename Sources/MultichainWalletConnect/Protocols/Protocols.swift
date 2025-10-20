// MARK: - Network Manager Protocol
// This file defines the protocol for network-specific wallet managers

import Foundation

// MARK: - Network Manager Protocol

public protocol NetworkManagerProtocol: Sendable {
    func connectWallet(_ walletType: WalletType) async throws -> WalletInfo
    func disconnectWallet(_ walletInfo: WalletInfo) async
    func sendTransaction(_ transaction: TransactionRequest) async throws -> String
    func getBalance(address: String, token: String?) async throws -> Decimal
    func getAvailableWallets() -> [WalletInfo]
}

// MARK: - Wallet Manager Protocol

@MainActor
public protocol WalletManagerProtocol: Sendable {
    func connectWallet(_ walletType: WalletType, network: SupportedNetwork?) async throws -> WalletInfo
    func disconnectWallet(_ walletInfo: WalletInfo) async
    func sendTransaction(_ transaction: TransactionRequest) async throws -> String
    func getBalance(for address: String, network: SupportedNetwork, token: String?) async throws -> Decimal
    func getAvailableWallets(for network: SupportedNetwork?) -> [WalletInfo]
}

// MARK: - QR Code Generator Protocol

public protocol QRCodeGeneratorProtocol: Sendable {
    func generateQRCode(from string: String, size: CGSize) async throws -> String
    func generateConnectionQR(for walletType: WalletType, network: SupportedNetwork) async throws -> String
}
