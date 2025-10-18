import Testing
import Foundation
import MultichainWalletConnect

// MARK: - Basic Tests

@Test("WalletInfo should be created correctly")
func testWalletInfoCreation() async throws {
    let wallet = WalletInfo(
        id: "test-id",
        name: "Test Wallet",
        address: "0x1234567890abcdef1234567890abcdef12345678",
        network: .ethereum,
        walletType: .metamask,
        isConnected: true,
        balance: 100.5,
        lastConnected: Date()
    )
    
    #expect(wallet.id == "test-id")
    #expect(wallet.name == "Test Wallet")
    #expect(wallet.address == "0x1234567890abcdef1234567890abcdef12345678")
    #expect(wallet.network == .ethereum)
    #expect(wallet.walletType == .metamask)
    #expect(wallet.isConnected == true)
    #expect(wallet.balance == 100.5)
}

@Test("NetworkInfo should be created from network")
func testNetworkInfoCreation() async throws {
    let networkInfo = NetworkInfo.from(network: .ethereum)
    
    #expect(networkInfo.name == "Ethereum Mainnet")
    #expect(networkInfo.chainId == "ethereum-mainnet")
    #expect(networkInfo.nativeToken == "ETH")
    #expect(networkInfo.decimals == 18)
    #expect(networkInfo.isTestnet == false)
}

@Test("TransactionRequest should be created correctly")
func testTransactionRequestCreation() async throws {
    let transaction = TransactionRequest(
        to: "0x1234567890abcdef1234567890abcdef12345678",
        amount: 1.0,
        token: "ETH",
        note: "Test transaction",
        from: "0xabcdef1234567890abcdef1234567890abcdef12",
        gasLimit: 21000,
        gasPrice: 0.00002
    )
    
    #expect(transaction.to == "0x1234567890abcdef1234567890abcdef12345678")
    #expect(transaction.amount == 1.0)
    #expect(transaction.token == "ETH")
    #expect(transaction.note == "Test transaction")
    #expect(transaction.from == "0xabcdef1234567890abcdef1234567890abcdef12")
    #expect(transaction.gasLimit == 21000)
    #expect(transaction.gasPrice == 0.00002)
}

// MARK: - Configuration Tests

@Test("ConfigurationManager should load default configuration")
func testConfigurationManagerDefault() async throws {
    let config = ConfigurationManager.shared.configuration
    
    #expect(!config.walletConnectProjectId.isEmpty)
    #expect(!config.walletConnectSessionId.isEmpty)
}

// MARK: - QR Code Generator Tests

@Test("QRCodeGenerator should be created")
func testQRCodeGeneratorCreation() async throws {
    let generator = QRCodeGenerator()
    
    // Just test that the generator can be created
    #expect(true) // Generator created successfully
}

// MARK: - MultichainWalletManager Tests

@Test("MultichainWalletManager should initialize")
func testMultichainWalletManagerInitialization() async throws {
    let manager = await MultichainWalletManager.shared
    
    // Verify that managers are configured by checking available wallets
    let availableWallets = await manager.getAvailableWallets()
    #expect(!availableWallets.isEmpty)
}

@Test("MultichainWalletManager should connect wallet")
func testMultichainWalletManagerConnect() async throws {
    let manager = await MultichainWalletManager.shared
    
    let wallet = try await manager.connectWallet(.metamask, network: .ethereum)
    
    #expect(wallet.walletType == .metamask)
    #expect(wallet.network == .ethereum)
    #expect(wallet.isConnected == true)
    #expect(!wallet.address.isEmpty)
}

@Test("MultichainWalletManager should send transaction")
func testMultichainWalletManagerSendTransaction() async throws {
    let manager = await MultichainWalletManager.shared
    
    // First connect a wallet
    let wallet = try await manager.connectWallet(.metamask, network: .ethereum)
    
    let transaction = TransactionRequest(
        to: "0x1234567890abcdef1234567890abcdef12345678",
        amount: 1.0,
        token: "ETH",
        note: "Test",
        from: wallet.address
    )
    
    let txHash = try await manager.sendTransaction(transaction)
    
    #expect(!txHash.isEmpty)
    #expect(txHash.hasPrefix("0x"))
}

@Test("MultichainWalletManager should get balance")
func testMultichainWalletManagerGetBalance() async throws {
    let manager = await MultichainWalletManager.shared
    
    let balance = try await manager.getBalance(for: "0x1234567890abcdef1234567890abcdef12345678", network: .ethereum)
    
    #expect(balance > 0)
    #expect(balance <= 1000) // Mock balance range
}

// MARK: - Error Tests

@Test("WalletError should have proper descriptions")
func testWalletError() async throws {
    let errors: [WalletError] = [
        .unsupportedNetwork,
        .noWalletConnected,
        .connectionFailed,
        .transactionFailed,
        .invalidConfiguration,
        .invalidQRCode,
        .custom("Test error")
    ]
    
    for error in errors {
        #expect(!error.localizedDescription.isEmpty)
    }
}