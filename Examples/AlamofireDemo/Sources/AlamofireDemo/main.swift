import Foundation
import MultichainWalletConnect
import Alamofire

// MARK: - Alamofire Demo App

print("🚀 Iniciando Alamofire Demo con MultichainWalletConnect")
print("========================================================")
print("")

// Configurar MultichainWalletConnect
let walletManager = MultichainWalletManager.shared

// Demo de conexión de billeteras
print("🔗 Demo de Conexión de Billeteras:")
print("")

Task {
    do {
        // Conectar a TON
        print("1. Conectando a TON...")
        let tonWallet = try await walletManager.connectWallet(.tonkeeper, network: .ton)
        print("   ✅ Conectado: \(tonWallet.name)")
        print("   📍 Dirección: \(tonWallet.address)")
        print("   💰 Balance: \(tonWallet.balance?.description ?? "No disponible")")
        print("")
        
        // Conectar a Algorand
        print("2. Conectando a Algorand...")
        let algoWallet = try await walletManager.connectWallet(.pera, network: .algorand)
        print("   ✅ Conectado: \(algoWallet.name)")
        print("   📍 Dirección: \(algoWallet.address)")
        print("   💰 Balance: \(algoWallet.balance?.description ?? "No disponible")")
        print("")
        
        // Demo de transacciones
        print("💸 Demo de Transacciones:")
        print("")
        
        let transaction = TransactionRequest(
            to: "ALGORAND_ADDRESS_EXAMPLE_123456789",
            amount: Decimal(10.5),
            token: "ALGO",
            note: "Demo transaction",
            from: algoWallet.address
        )
        
        print("3. Enviando transacción...")
        let txHash = try await walletManager.sendTransaction(transaction)
        print("   ✅ Transacción enviada: \(txHash)")
        print("")
        
        // Demo de QR
        print("📱 Demo de Códigos QR:")
        print("")
        
        let qrGenerator = QRCodeGenerator()
        let qrCode = try await qrGenerator.generateConnectionQR(for: .phantom, network: .solana)
        print("4. QR generado: \(qrCode)")
        print("")
        
        print("🎉 Demo completada exitosamente!")
        
    } catch {
        print("❌ Error en demo: \(error.localizedDescription)")
    }
}

// Mantener la app corriendo
RunLoop.main.run()
