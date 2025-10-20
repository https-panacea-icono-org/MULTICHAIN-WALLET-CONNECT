// MARK: - QR Code Generator
// This file handles QR code generation for wallet connections

import Foundation
import CoreImage

#if canImport(UIKit)
import UIKit
#endif

// MARK: - QR Code Generator

public final class QRCodeGenerator: QRCodeGeneratorProtocol, @unchecked Sendable {
    
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
