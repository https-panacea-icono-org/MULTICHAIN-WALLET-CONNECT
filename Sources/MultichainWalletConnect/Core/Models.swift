// MARK: - Core Models for MultichainWalletConnect
// This file contains the fundamental data structures used throughout the SDK

import Foundation

// MARK: - Wallet Info

public struct WalletInfo: Identifiable, Codable, Equatable, Sendable {
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

// MARK: - Transaction Request

public struct TransactionRequest: Codable, Sendable {
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

public struct WalletConnectionData: Codable, Sendable {
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

// MARK: - Wallet Error

public enum WalletError: LocalizedError, Sendable {
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
