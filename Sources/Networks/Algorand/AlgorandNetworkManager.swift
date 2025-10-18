import Foundation

/// Gestor de red Algorand para conexión con Pera Wallet y otras billeteras Algorand
public class AlgorandNetworkManager: NetworkManagerProtocol {
    
    // MARK: - Properties
    private let peraWalletManager: PeraWalletManager
    private let myAlgoManager: MyAlgoManager
    private let walletConnectManager: AlgorandWalletConnectManager
    private var connectedWallet: WalletInfo?
    
    // MARK: - Initialization
    public init() {
        self.peraWalletManager = PeraWalletManager()
        self.myAlgoManager = MyAlgoManager()
        self.walletConnectManager = AlgorandWalletConnectManager()
    }
    
    // MARK: - NetworkManagerProtocol
    
    public func connectWallet(_ walletType: WalletType) async throws -> WalletInfo {
        switch walletType {
        case .pera:
            return try await connectPeraWallet()
        case .myalgo:
            return try await connectMyAlgo()
        case .walletconnect:
            return try await connectViaWalletConnect()
        default:
            throw AlgorandError.unsupportedWallet
        }
    }
    
    public func disconnectWallet(_ walletInfo: WalletInfo) async {
        connectedWallet = nil
        
        switch walletInfo.walletType {
        case .pera:
            await peraWalletManager.disconnect()
        case .myalgo:
            await myAlgoManager.disconnect()
        case .walletconnect:
            await walletConnectManager.disconnect()
        default:
            break
        }
    }
    
    public func sendTransaction(_ transaction: TransactionRequest) async throws -> String {
        guard let connectedWallet = connectedWallet else {
            throw AlgorandError.noWalletConnected
        }
        
        return try await sendAlgorandTransaction(transaction, from: connectedWallet)
    }
    
    public func getBalance(address: String, token: String?) async throws -> Decimal {
        if let token = token, token != "ALGO" {
            return try await getAssetBalance(address: address, assetId: token)
        } else {
            return try await getAlgoBalance(address: address)
        }
    }
    
    public func getAvailableWallets() -> [WalletInfo] {
        return [
            WalletInfo(
                name: "Pera Wallet",
                address: "",
                network: .algorand,
                walletType: .pera,
                isConnected: connectedWallet?.walletType == .pera
            ),
            WalletInfo(
                name: "MyAlgo",
                address: "",
                network: .algorand,
                walletType: .myalgo,
                isConnected: connectedWallet?.walletType == .myalgo
            ),
            WalletInfo(
                name: "WalletConnect",
                address: "",
                network: .algorand,
                walletType: .walletconnect,
                isConnected: connectedWallet?.walletType == .walletconnect
            )
        ]
    }
    
    // MARK: - Private Methods
    
    private func connectPeraWallet() async throws -> WalletInfo {
        return try await peraWalletManager.connect()
    }
    
    private func connectMyAlgo() async throws -> WalletInfo {
        return try await myAlgoManager.connect()
    }
    
    private func connectViaWalletConnect() async throws -> WalletInfo {
        return try await walletConnectManager.connect()
    }
    
    private func sendAlgorandTransaction(_ transaction: TransactionRequest, from wallet: WalletInfo) async throws -> String {
        // Implementar envío de transacción Algorand
        // Por ahora simulamos el envío
        let txId = "ALGO_TX_\(UUID().uuidString.prefix(8))"
        return txId
    }
    
    private func signTransaction(_ transaction: TransactionRequest, with wallet: WalletInfo) async throws -> String {
        // Implementar firma de transacción según el tipo de wallet
        switch wallet.walletType {
        case .pera:
            return try await peraWalletManager.signTransaction(transaction)
        case .myalgo:
            return try await myAlgoManager.signTransaction(transaction)
        case .walletconnect:
            return try await walletConnectManager.signTransaction(transaction)
        default:
            throw AlgorandError.unsupportedWallet
        }
    }
    
    private func getAlgoBalance(address: String) async throws -> Decimal {
        // Implementar obtención de balance ALGO
        // Por ahora simulamos un balance
        return Decimal(100.0)
    }
    
    private func getAssetBalance(address: String, assetId: String) async throws -> Decimal {
        // Implementar obtención de balance de asset Algorand
        // Por ahora simulamos un balance
        return Decimal(1000.0)
    }
}

// MARK: - Pera Wallet Manager

public class PeraWalletManager: ObservableObject {
    
    @Published public var isConnected: Bool = false
    @Published public var walletAddress: String?
    @Published public var connectionStatus: PeraConnectionStatus = .disconnected
    
    private let deepLinkHandler = PeraDeepLinkHandler()
    
    public init() {}
    
    public func connect() async throws -> WalletInfo {
        guard isPeraInstalled() else {
            throw AlgorandError.walletNotInstalled
        }
        
        connectionStatus = .connecting
        
        do {
            let deepLink = try createConnectionDeepLink()
            try await openPeraWallet(deepLink: deepLink)
            
            let result = try await waitForConnectionResponse()
            
            walletAddress = result.address
            isConnected = true
            connectionStatus = .connected
            
            return WalletInfo(
                name: "Pera Wallet",
                address: result.address,
                network: .algorand,
                walletType: .pera,
                isConnected: true,
                lastConnected: Date()
            )
            
        } catch {
            connectionStatus = .failed
            throw error
        }
    }
    
    public func disconnect() async {
        isConnected = false
        walletAddress = nil
        connectionStatus = .disconnected
    }
    
    public func signTransaction(_ transaction: TransactionRequest) async throws -> String {
        guard isConnected, let address = walletAddress else {
            throw AlgorandError.notConnected
        }
        
        let deepLink = try createSigningDeepLink(transaction)
        try await openPeraWallet(deepLink: deepLink)
        
        return try await waitForSigningResponse()
    }
    
    private func isPeraInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "algorand://")!)
    }
    
    private func createConnectionDeepLink() throws -> String {
        let sessionId = UUID().uuidString
        let returnURL = "panacea://pera-connected"
        
        // Configurar para Algorand mainnet específicamente
        let deepLink = "algorand://wallet/connect?session_id=\(sessionId)&return_url=\(returnURL)&network=mainnet"
        
        guard let encodedURL = deepLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw AlgorandError.invalidDeepLink
        }
        
        return encodedURL
    }
    
    private func createSigningDeepLink(_ transaction: TransactionRequest) throws -> String {
        let txData = try JSONEncoder().encode(transaction)
        let txBase64 = txData.base64EncodedString()
        
        let deepLink = "algorand://wallet/sign?transaction=\(txBase64)&return_url=panacea://transaction-signed"
        
        guard let encodedURL = deepLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw AlgorandError.invalidDeepLink
        }
        
        return encodedURL
    }
    
    private func openPeraWallet(deepLink: String) async throws {
        guard let url = URL(string: deepLink) else {
            throw AlgorandError.invalidDeepLink
        }
        
        await UIApplication.shared.open(url)
    }
    
    private func waitForConnectionResponse() async throws -> PeraConnectionResult {
        return try await withCheckedThrowingContinuation { continuation in
            deepLinkHandler.onConnectionResult = { result in
                continuation.resume(returning: result)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                if continuation.isCancelled == false {
                    continuation.resume(throwing: AlgorandError.connectionTimeout)
                }
            }
        }
    }
    
    private func waitForSigningResponse() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            deepLinkHandler.onSigningResult = { result in
                continuation.resume(with: result)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                if continuation.isCancelled == false {
                    continuation.resume(throwing: AlgorandError.signingTimeout)
                }
            }
        }
    }
}

// MARK: - MyAlgo Manager

public class MyAlgoManager: ObservableObject {
    
    @Published public var isConnected: Bool = false
    @Published public var walletAddress: String?
    
    public init() {}
    
    public func connect() async throws -> WalletInfo {
        // Implementar conexión con MyAlgo
        // Por ahora simulamos la conexión
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let walletInfo = WalletInfo(
                    name: "MyAlgo",
                    address: "ALGORAND_ADDRESS_EXAMPLE",
                    network: .algorand,
                    walletType: .myalgo,
                    isConnected: true,
                    lastConnected: Date()
                )
                continuation.resume(returning: walletInfo)
            }
        }
    }
    
    public func disconnect() async {
        isConnected = false
        walletAddress = nil
    }
    
    public func signTransaction(_ transaction: TransactionRequest) async throws -> String {
        // Implementar firma de transacción con MyAlgo
        return "MYALGO_SIGNED_TX_\(UUID().uuidString.prefix(8))"
    }
}

// MARK: - Algorand WalletConnect Manager

public class AlgorandWalletConnectManager: ObservableObject {
    
    private var session: WalletConnectSession?
    
    public init() {}
    
    public func connect() async throws -> WalletInfo {
        // Implementar conexión WalletConnect para Algorand
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let walletInfo = WalletInfo(
                    name: "WalletConnect Algorand",
                    address: "ALGORAND_ADDRESS_EXAMPLE",
                    network: .algorand,
                    walletType: .walletconnect,
                    isConnected: true,
                    lastConnected: Date()
                )
                continuation.resume(returning: walletInfo)
            }
        }
    }
    
    public func disconnect() async {
        session = nil
    }
    
    public func signTransaction(_ transaction: TransactionRequest) async throws -> String {
        // Implementar firma de transacción via WalletConnect
        return "WALLETCONNECT_SIGNED_TX_\(UUID().uuidString.prefix(8))"
    }
}

// MARK: - Pera Deep Link Handler

public class PeraDeepLinkHandler: ObservableObject {
    
    public var onConnectionResult: ((PeraConnectionResult) -> Void)?
    public var onSigningResult: ((Result<String, Error>) -> Void)?
    
    public init() {
        setupURLSchemeHandler()
    }
    
    private func setupURLSchemeHandler() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleURLScheme(_:)),
            name: NSNotification.Name("PeraResponse"),
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
        case "pera-connected":
            handleConnectionResponse(url)
        case "transaction-signed":
            handleSigningResponse(url)
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
        
        let result = PeraConnectionResult(
            success: success,
            address: address,
            error: success ? nil : AlgorandError.connectionFailed
        )
        
        onConnectionResult?(result)
    }
    
    private func handleSigningResponse(_ url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        
        var signedTx: String?
        var success = false
        
        for item in queryItems {
            switch item.name {
            case "signed_transaction":
                signedTx = item.value
            case "success":
                success = item.value == "true"
            default:
                break
            }
        }
        
        if success, let signedTxData = signedTx {
            onSigningResult?(.success(signedTxData))
        } else {
            onSigningResult?(.failure(AlgorandError.signingFailed))
        }
    }
}

// MARK: - Supporting Types

public enum PeraConnectionStatus {
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

public struct PeraConnectionResult {
    let success: Bool
    let address: String?
    let error: Error?
}

public enum AlgorandError: LocalizedError {
    case unsupportedWallet
    case walletNotInstalled
    case notConnected
    case connectionFailed
    case connectionTimeout
    case signingTimeout
    case signingFailed
    case noWalletConnected
    case transactionFailed
    case invalidDeepLink
    
    public var errorDescription: String? {
        switch self {
        case .unsupportedWallet:
            return "Billetera no soportada"
        case .walletNotInstalled:
            return "Billetera no instalada"
        case .notConnected:
            return "No hay conexión con la billetera"
        case .connectionFailed:
            return "Error al conectar con la billetera"
        case .connectionTimeout:
            return "Tiempo de espera agotado para conexión"
        case .signingTimeout:
            return "Tiempo de espera agotado para firma"
        case .signingFailed:
            return "Error al firmar transacción"
        case .noWalletConnected:
            return "No hay billetera conectada"
        case .transactionFailed:
            return "Error al enviar transacción"
        case .invalidDeepLink:
            return "Enlace de conexión inválido"
        }
    }
}

// MARK: - Import Statements

#if canImport(UIKit)
import UIKit
#endif
