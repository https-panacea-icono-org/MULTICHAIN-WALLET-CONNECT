import Foundation
import CoreImage
#if canImport(UIKit)
import UIKit
#endif

/// Generador de códigos QR para conexión de billeteras
public class QRCodeGenerator {
    
    // MARK: - Properties
    private let context = CIContext()
    
    // MARK: - Public Methods
    
    /// Generar código QR para conexión de billetera
    public func generateQRCode(
        for connectionData: WalletConnectionData,
        size: CGSize = CGSize(width: 300, height: 300)
    ) async throws -> String {
        
        let jsonString = try encodeConnectionData(connectionData)
        return jsonString // Por ahora retornamos el string directamente
    }
    
    /// Generar código QR para WalletConnect
    public func generateWalletConnectQR(
        sessionId: String,
        network: SupportedNetwork,
        size: CGSize = CGSize(width: 300, height: 300)
    ) async throws -> String {
        
        let walletConnectURL = createWalletConnectURL(sessionId: sessionId, network: network)
        return walletConnectURL // Por ahora retornamos el string directamente
    }
    
    /// Generar código QR para deep link de billetera
    public func generateDeepLinkQR(
        for walletType: WalletType,
        network: SupportedNetwork,
        size: CGSize = CGSize(width: 300, height: 300)
    ) async throws -> String {
        
        let deepLink = createDeepLink(for: walletType, network: network)
        return deepLink // Por ahora retornamos el string directamente
    }
    
    // MARK: - Private Methods
    
    private func encodeConnectionData(_ data: WalletConnectionData) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let jsonData = try encoder.encode(data)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw QRCodeError.encodingFailed
        }
        
        return jsonString
    }
    
    private func generateQRCode(from string: String, size: CGSize) async throws -> String {
        // Implementación simplificada - por ahora retornamos el string
        return string
    }
    
    private func createWalletConnectURL(sessionId: String, network: SupportedNetwork) -> String {
        let baseURL = "wc:\(sessionId)@2?bridge=https%3A%2F%2Fbridge.walletconnect.org&key=\(generateRandomKey())"
        return baseURL
    }
    
    private func createDeepLink(for walletType: WalletType, network: SupportedNetwork) -> String {
        switch walletType {
        case .tonkeeper:
            return "tonkeeper://connect?network=\(network.rawValue)"
        case .tonwallet:
            return "tonwallet://connect?network=\(network.rawValue)"
        case .pera:
            return "algorand://connect?network=\(network.rawValue)"
        case .myalgo:
            return "myalgo://connect?network=\(network.rawValue)"
        case .phantom:
            return "phantom://connect?network=\(network.rawValue)"
        case .solflare:
            return "solflare://connect?network=\(network.rawValue)"
        case .metamask:
            return "metamask://connect?network=\(network.rawValue)"
        case .walletconnect:
            return createWalletConnectURL(sessionId: UUID().uuidString, network: network)
        }
    }
    
    private func generateRandomKey() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<32).map { _ in characters.randomElement()! })
    }
}

// MARK: - QR Code Scanner

public class QRCodeScanner: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published public var isScanning = false
    @Published public var scannedCode: String?
    @Published public var error: QRCodeError?
    
    // MARK: - Private Properties
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var onCodeScanned: ((String) -> Void)?
    
    // MARK: - Public Methods
    
    public func startScanning(onCodeScanned: @escaping (String) -> Void) {
        self.onCodeScanned = onCodeScanned
        setupCaptureSession()
        isScanning = true
    }
    
    public func stopScanning() {
        captureSession?.stopRunning()
        isScanning = false
    }
    
    public func createPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }
    
    // MARK: - Private Methods
    
    private func setupCaptureSession() {
        #if canImport(UIKit)
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            error = .cameraNotAvailable
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let output = AVCaptureMetadataOutput()
            captureSession?.addOutput(output)
            
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr]
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.videoGravity = .resizeAspectFill
            
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.captureSession?.startRunning()
            }
            
        } catch {
            self.error = .setupFailed
        }
        #endif
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

#if canImport(UIKit)
extension QRCodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        
        scannedCode = stringValue
        onCodeScanned?(stringValue)
        stopScanning()
    }
}
#endif

// MARK: - QR Code Errors

public enum QRCodeError: LocalizedError {
    case encodingFailed
    case invalidInput
    case generationFailed
    case imageCreationFailed
    case cameraNotAvailable
    case setupFailed
    case scanningFailed
    
    public var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Error al codificar datos para QR"
        case .invalidInput:
            return "Entrada inválida para generar QR"
        case .generationFailed:
            return "Error al generar código QR"
        case .imageCreationFailed:
            return "Error al crear imagen del QR"
        case .cameraNotAvailable:
            return "Cámara no disponible"
        case .setupFailed:
            return "Error al configurar escáner"
        case .scanningFailed:
            return "Error al escanear código QR"
        }
    }
}

// MARK: - Import Statements

#if canImport(AVFoundation)
import AVFoundation
#endif