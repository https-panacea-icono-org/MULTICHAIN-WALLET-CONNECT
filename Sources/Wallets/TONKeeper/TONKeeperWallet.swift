import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Implementación específica para TONKeeper Wallet
public class TONKeeperWallet: ObservableObject {
    
    // MARK: - Properties
    @Published public var isConnected: Bool = false
    @Published public var walletAddress: String?
    @Published public var balance: Decimal?
    @Published public var connectionStatus: TONKeeperConnectionStatus = .disconnected
    
    private let deepLinkHandler = TONKeeperDeepLinkHandler()
    private let balanceManager = TONBalanceManager()
    
    // MARK: - Public Methods
    
    /// Conectar a TONKeeper
    public func connect() async throws {
        guard isTONKeeperInstalled() else {
            throw TONKeeperError.notInstalled
        }
        
        connectionStatus = .connecting
        
        do {
            let deepLink = try createConnectionDeepLink()
            try await openTONKeeper(deepLink: deepLink)
            
            // Esperar respuesta de TONKeeper
            let result = try await waitForConnectionResponse()
            
            walletAddress = result.address
            isConnected = true
            connectionStatus = .connected
            
            // Obtener balance inicial
            if let address = walletAddress {
                balance = try await balanceManager.getBalance(for: address)
            }
            
        } catch {
            connectionStatus = .failed
            throw error
        }
    }
    
    /// Desconectar de TONKeeper
    public func disconnect() {
        isConnected = false
        walletAddress = nil
        balance = nil
        connectionStatus = .disconnected
    }
    
    /// Enviar transacción TON
    public func sendTransaction(
        to address: String,
        amount: Decimal,
        message: String? = nil
    ) async throws -> String {
        guard isConnected, let fromAddress = walletAddress else {
            throw TONKeeperError.notConnected
        }
        
        let transaction = TONTransaction(
            from: fromAddress,
            to: address,
            amount: amount,
            message: message ?? ""
        )
        
        return try await sendTransactionViaDeepLink(transaction)
    }
    
    /// Obtener balance actualizado
    public func refreshBalance() async throws {
        guard let address = walletAddress else {
            throw TONKeeperError.notConnected
        }
        
        balance = try await balanceManager.getBalance(for: address)
    }
    
    /// Verificar si TONKeeper está instalado
    public func isTONKeeperInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "tonkeeper://")!)
    }
    
    // MARK: - Private Methods
    
    private func createConnectionDeepLink() throws -> String {
        let sessionId = UUID().uuidString
        let returnURL = "panacea://tonkeeper-connected"
        
        // Configurar para mainnet específicamente
        let deepLink = "tonkeeper://connect?session_id=\(sessionId)&return_url=\(returnURL)&network=mainnet"
        
        guard let encodedURL = deepLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw TONKeeperError.invalidDeepLink
        }
        
        return encodedURL
    }
    
    private func openTONKeeper(deepLink: String) async throws {
        guard let url = URL(string: deepLink) else {
            throw TONKeeperError.invalidDeepLink
        }
        
        await UIApplication.shared.open(url)
    }
    
    private func waitForConnectionResponse() async throws -> TONKeeperConnectionResult {
        return try await withCheckedThrowingContinuation { continuation in
            // Configurar listener para respuesta de TONKeeper
            deepLinkHandler.onConnectionResult = { result in
                continuation.resume(returning: result)
            }
            
            // Timeout después de 30 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                if continuation.isCancelled == false {
                    continuation.resume(throwing: TONKeeperError.connectionTimeout)
                }
            }
        }
    }
    
    private func sendTransactionViaDeepLink(_ transaction: TONTransaction) async throws -> String {
        let deepLink = createTransactionDeepLink(transaction)
        
        guard let url = URL(string: deepLink) else {
            throw TONKeeperError.invalidDeepLink
        }
        
        await UIApplication.shared.open(url)
        
        // Esperar confirmación de transacción
        return try await waitForTransactionConfirmation()
    }
    
    private func createTransactionDeepLink(_ transaction: TONTransaction) -> String {
        let amount = Int(transaction.amount * 1_000_000_000) // Convertir a nanotons
        
        var components = URLComponents()
        components.scheme = "tonkeeper"
        components.host = "transfer"
        components.queryItems = [
            URLQueryItem(name: "to", value: transaction.to),
            URLQueryItem(name: "amount", value: String(amount)),
            URLQueryItem(name: "text", value: transaction.message),
            URLQueryItem(name: "return_url", value: "panacea://transaction-completed")
        ]
        
        return components.url?.absoluteString ?? ""
    }
    
    private func waitForTransactionConfirmation() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            deepLinkHandler.onTransactionResult = { result in
                switch result {
                case .success(let txHash):
                    continuation.resume(returning: txHash)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            // Timeout después de 60 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                if continuation.isCancelled == false {
                    continuation.resume(throwing: TONKeeperError.transactionTimeout)
                }
            }
        }
    }
}

// MARK: - TONKeeper Deep Link Handler

public class TONKeeperDeepLinkHandler: ObservableObject {
    
    public var onConnectionResult: ((TONKeeperConnectionResult) -> Void)?
    public var onTransactionResult: ((Result<String, Error>) -> Void)?
    
    public init() {
        setupURLSchemeHandler()
    }
    
    private func setupURLSchemeHandler() {
        // Configurar manejo de URL schemes para respuestas de TONKeeper
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleURLScheme(_:)),
            name: NSNotification.Name("TONKeeperResponse"),
            object: nil
        )
    }
    
    @objc private func handleURLScheme(_ notification: Notification) {
        guard let url = notification.object as? URL else { return }
        
        if url.scheme == "panacea" {
            handlePanaceaResponse(url)
        }
    }
    
    private func handlePanaceaResponse(_ url: URL) {
        switch url.host {
        case "tonkeeper-connected":
            handleConnectionResponse(url)
        case "transaction-completed":
            handleTransactionResponse(url)
        default:
            break
        }
    }
    
    private func handleConnectionResponse(_ url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        
        var address: String?
        var success = false
        
        for item in queryItems {
            switch item.name {
            case "address":
                address = item.value
            case "success":
                success = item.value == "true"
            default:
                break
            }
        }
        
        let result = TONKeeperConnectionResult(
            success: success,
            address: address,
            error: success ? nil : TONKeeperError.connectionFailed
        )
        
        onConnectionResult?(result)
    }
    
    private func handleTransactionResponse(_ url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        
        var txHash: String?
        var success = false
        
        for item in queryItems {
            switch item.name {
            case "tx_hash":
                txHash = item.value
            case "success":
                success = item.value == "true"
            default:
                break
            }
        }
        
        if success, let hash = txHash {
            onTransactionResult?(.success(hash))
        } else {
            onTransactionResult?(.failure(TONKeeperError.transactionFailed))
        }
    }
}

// MARK: - TON Balance Manager

public class TONBalanceManager {
    
    private let tonAPI = TONAPI()
    
    public func getBalance(for address: String) async throws -> Decimal {
        return try await tonAPI.getBalance(address: address)
    }
}

// MARK: - TON API

public class TONAPI {
    
    private let baseURL = "https://toncenter.com/api/v2"
    
    public func getBalance(address: String) async throws -> Decimal {
        let url = "\(baseURL)/getAddressBalance?address=\(address)"
        
        guard let requestURL = URL(string: url) else {
            throw TONKeeperError.invalidAPIURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: requestURL)
        let response = try JSONDecoder().decode(TONBalanceResponse.self, from: data)
        
        // Convertir de nanotons a TON
        let balance = Decimal(response.result) / 1_000_000_000
        return balance
    }
}

// MARK: - Supporting Types

public enum TONKeeperConnectionStatus {
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

public struct TONKeeperConnectionResult {
    let success: Bool
    let address: String?
    let error: Error?
}

public struct TONTransaction {
    let from: String
    let to: String
    let amount: Decimal
    let message: String
}

public struct TONBalanceResponse: Codable {
    let result: String
}

public enum TONKeeperError: LocalizedError {
    case notInstalled
    case notConnected
    case invalidDeepLink
    case connectionTimeout
    case transactionTimeout
    case connectionFailed
    case transactionFailed
    case invalidAPIURL
    
    public var errorDescription: String? {
        switch self {
        case .notInstalled:
            return "TONKeeper no está instalado"
        case .notConnected:
            return "No hay conexión con TONKeeper"
        case .invalidDeepLink:
            return "Enlace de conexión inválido"
        case .connectionTimeout:
            return "Tiempo de espera agotado para conexión"
        case .transactionTimeout:
            return "Tiempo de espera agotado para transacción"
        case .connectionFailed:
            return "Error al conectar con TONKeeper"
        case .transactionFailed:
            return "Error al enviar transacción"
        case .invalidAPIURL:
            return "URL de API inválida"
        }
    }
}
