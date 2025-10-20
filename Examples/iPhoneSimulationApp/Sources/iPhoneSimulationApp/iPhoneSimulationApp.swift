import Foundation
import SwiftUI
import MultichainWalletConnect

// MARK: - iPhone 17/17 Pro Simulation App

@main
struct iPhoneSimulationApp: App {
    @StateObject private var walletManager = MultichainWalletManager.shared
    @State private var selectedNetwork: SupportedNetwork = .ethereum
    @State private var selectedWallet: WalletType = .metamask
    @State private var isConnected = false
    @State private var connectedWallet: WalletInfo?
    @State private var balance: Decimal = 0
    @State private var qrCode: String = ""
    @State private var showingQR = false
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack(spacing: 20) {
                    // MARK: - Header
                    VStack {
                        Text("🚀 Multichain Wallet Connect")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("iPhone 17/17 Pro Simulation")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // MARK: - Network Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("🌐 Select Network")
                            .font(.headline)
                        
                        Picker("Network", selection: $selectedNetwork) {
                            ForEach(SupportedNetwork.allCases, id: \.self) { network in
                                Text(network.displayName)
                                    .tag(network)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedNetwork) { _, _ in
                            updateAvailableWallets()
                        }
                    }
                    .padding()
                    
                    // MARK: - Wallet Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("💳 Select Wallet")
                            .font(.headline)
                        
                        let availableWallets = walletManager.getAvailableWallets(for: selectedNetwork)
                        
                        if availableWallets.isEmpty {
                            Text("No wallets available for \(selectedNetwork.displayName)")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(availableWallets, id: \.id) { wallet in
                                WalletCard(
                                    wallet: wallet,
                                    isSelected: selectedWallet == wallet.walletType,
                                    onTap: {
                                        selectedWallet = wallet.walletType
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                    
                    // MARK: - Connection Status
                    if isConnected, let wallet = connectedWallet {
                        VStack(spacing: 15) {
                            Text("✅ Connected")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Wallet: \(wallet.name)")
                                Text("Address: \(wallet.address)")
                                Text("Balance: \(balance) \(NetworkInfo.from(network: wallet.network).nativeToken)")
                            }
                            .font(.caption)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            
                            Button("🔌 Disconnect") {
                                Task {
                                    await walletManager.disconnectWallet(wallet)
                                    isConnected = false
                                    connectedWallet = nil
                                    balance = 0
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                        .padding()
                    } else {
                        Button("🔗 Connect Wallet") {
                            Task {
                                await connectWallet()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(walletManager.isConnecting)
                    }
                    
                    // MARK: - QR Code Generation
                    if isConnected {
                        VStack(spacing: 10) {
                            Button("📱 Generate QR Code") {
                                Task {
                                    await generateQRCode()
                                }
                            }
                            .buttonStyle(.bordered)
                            
                            if !qrCode.isEmpty {
                                Button("👁️ Show QR Code") {
                                    showingQR = true
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                    }
                    
                    // MARK: - Transaction Simulation
                    if isConnected {
                        VStack(spacing: 10) {
                            Text("📤 Send Transaction")
                                .font(.headline)
                            
                            Button("💰 Send 0.1 Token") {
                                Task {
                                    await sendTransaction()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
                .navigationTitle("Wallet Connect")
                .sheet(isPresented: $showingQR) {
                    QRCodeView(qrCode: qrCode)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateAvailableWallets() {
        let wallets = walletManager.getAvailableWallets(for: selectedNetwork)
        if let firstWallet = wallets.first {
            selectedWallet = firstWallet.walletType
        }
    }
    
    private func connectWallet() async {
        do {
            let wallet = try await walletManager.connectWallet(selectedWallet, network: selectedNetwork)
            connectedWallet = wallet
            isConnected = true
            
            // Get balance
            balance = try await walletManager.getBalance(for: wallet.address, network: wallet.network)
        } catch {
            print("Connection error: \(error)")
        }
    }
    
    private func generateQRCode() async {
        guard let wallet = connectedWallet else { return }
        
        do {
            let generator = QRCodeGenerator()
            qrCode = try await generator.generateConnectionQR(for: wallet.walletType, network: wallet.network)
        } catch {
            print("QR generation error: \(error)")
        }
    }
    
    private func sendTransaction() async {
        guard let wallet = connectedWallet else { return }
        
        let networkInfo = NetworkInfo.from(network: wallet.network)
        let transaction = TransactionRequest(
            to: "0x1234567890abcdef1234567890abcdef12345678",
            amount: 0.1,
            token: networkInfo.nativeToken,
            note: "iPhone 17 Simulation",
            from: wallet.address
        )
        
        do {
            let txHash = try await walletManager.sendTransaction(transaction)
            print("Transaction sent: \(txHash)")
        } catch {
            print("Transaction error: \(error)")
        }
    }
}

// MARK: - Wallet Card Component

struct WalletCard: View {
    let wallet: WalletInfo
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(wallet.name)
                        .font(.headline)
                    Text(wallet.walletType.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - QR Code View

struct QRCodeView: View {
    let qrCode: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("📱 Connection QR Code")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if !qrCode.isEmpty {
                    // Aquí se mostraría el QR code real
                    // Por ahora mostramos el string
                    Text(qrCode)
                        .font(.caption)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("QR Code")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
