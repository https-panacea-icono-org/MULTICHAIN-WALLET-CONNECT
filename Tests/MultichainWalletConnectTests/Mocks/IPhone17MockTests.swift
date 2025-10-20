import Testing
import Foundation
import MultichainWalletConnect

// MARK: - Mock Tests for iPhone 17/17 Pro

@Test("MockNetworkManager should support all networks")
func testMockNetworkManagerAllNetworks() async throws {
    let networks: [SupportedNetwork] = [.ethereum, .bitcoin, .solana, .polygon, .arbitrum, .optimism, .algorand, .ton]
    
    for network in networks {
        let mockManager = MockNetworkManagerFactory.createManagers(for: [network])[network]!
        
        // Test available wallets
        let wallets = mockManager.getAvailableWallets()
        #expect(!wallets.isEmpty)
        
        // Test wallet connection
        if let firstWallet = wallets.first {
            let connectedWallet = try await mockManager.connectWallet(firstWallet.walletType)
            #expect(connectedWallet.network == network)
            #expect(connectedWallet.isConnected == true)
            
            // Test balance retrieval
            let balance = try await mockManager.getBalance(address: connectedWallet.address, token: nil as String?)
            #expect(balance >= 0)
            
            // Test transaction sending
            let transaction = TransactionRequest(
                to: "0x1234567890abcdef1234567890abcdef12345678",
                amount: 0.1,
                token: NetworkInfo.from(network: network).nativeToken,
                note: "Mock Test",
                from: connectedWallet.address
            )
            
            let txHash = try await mockManager.sendTransaction(transaction)
            #expect(!txHash.isEmpty)
            
            // Test disconnection
            await mockManager.disconnectWallet(connectedWallet)
        }
    }
}

@Test("MockNetworkManager should generate deterministic addresses")
func testMockNetworkManagerDeterministicAddresses() async throws {
    let network = SupportedNetwork.ethereum
    let mockManager = MockNetworkManagerFactory.createManagers(for: [network])[network]!
    
    // Connect same wallet type multiple times
    let wallet1 = try await mockManager.connectWallet(.metamask)
    await mockManager.disconnectWallet(wallet1)
    
    let wallet2 = try await mockManager.connectWallet(.metamask)
    
    // Addresses should be deterministic
    #expect(wallet1.address == wallet2.address)
}

@Test("MockNetworkManager should handle concurrent connections")
func testMockNetworkManagerConcurrentConnections() async throws {
    let network = SupportedNetwork.ethereum
    let mockManager = MockNetworkManagerFactory.createManagers(for: [network])[network]!
    
    // Test concurrent connections
    async let wallet1 = mockManager.connectWallet(.metamask)
    async let wallet2 = mockManager.connectWallet(.walletconnect)
    
    let connectedWallet1 = try await wallet1
    let connectedWallet2 = try await wallet2
    
    #expect(connectedWallet1.walletType == .metamask)
    #expect(connectedWallet2.walletType == .walletconnect)
    #expect(connectedWallet1.address != connectedWallet2.address)
}

@Test("MockNetworkManager should provide realistic balances")
func testMockNetworkManagerRealisticBalances() async throws {
    let networks: [SupportedNetwork] = [.ethereum, .bitcoin, .solana, .polygon, .arbitrum, .optimism, .algorand, .ton]
    
    for network in networks {
        let mockManager = MockNetworkManagerFactory.createManagers(for: [network])[network]!
        let wallets = mockManager.getAvailableWallets()
        
        if let firstWallet = wallets.first {
            let connectedWallet = try await mockManager.connectWallet(firstWallet.walletType)
            let balance = try await mockManager.getBalance(address: connectedWallet.address, token: nil as String?)
            
            // Balance should be realistic for the network
            #expect(balance >= 0)
            #expect(balance <= 10000) // Reasonable upper limit for mock
            
            await mockManager.disconnectWallet(connectedWallet)
        }
    }
}

@Test("MockNetworkManager should generate valid transaction hashes")
func testMockNetworkManagerTransactionHashes() async throws {
    let networks: [SupportedNetwork] = [.ethereum, .bitcoin, .solana, .polygon, .arbitrum, .optimism, .algorand, .ton]
    
    for network in networks {
        let mockManager = MockNetworkManagerFactory.createManagers(for: [network])[network]!
        let wallets = mockManager.getAvailableWallets()
        
        if let firstWallet = wallets.first {
            let connectedWallet = try await mockManager.connectWallet(firstWallet.walletType)
            
            let transaction = TransactionRequest(
                to: "0x1234567890abcdef1234567890abcdef12345678",
                amount: 0.1,
                token: NetworkInfo.from(network: network).nativeToken,
                note: "Mock Test",
                from: connectedWallet.address
            )
            
            let txHash = try await mockManager.sendTransaction(transaction)
            
            // Transaction hash should be valid for the network
            #expect(!txHash.isEmpty)
            #expect(txHash.count >= 10) // Minimum length
            
            await mockManager.disconnectWallet(connectedWallet)
        }
    }
}

@Test("MockNetworkManager should handle disconnection correctly")
func testMockNetworkManagerDisconnection() async throws {
    let network = SupportedNetwork.ethereum
    let mockManager = MockNetworkManagerFactory.createManagers(for: [network])[network]!
    
    let wallet = try await mockManager.connectWallet(.metamask)
    #expect(wallet.isConnected == true)
    
    await mockManager.disconnectWallet(wallet)
    
    // After disconnection, sending transaction should fail
    let transaction = TransactionRequest(
        to: "0x1234567890abcdef1234567890abcdef12345678",
        amount: 0.1,
        token: "ETH",
        note: "Test",
        from: wallet.address
    )
    
    do {
        _ = try await mockManager.sendTransaction(transaction)
        // Si llegamos aquí, el test falla porque la transacción debería haber fallado
        #expect(Bool(false), "Transaction should fail after disconnection")
    } catch {
        #expect(error is WalletError)
    }
}

@Test("MockNetworkManager should be thread-safe")
func testMockNetworkManagerThreadSafety() async throws {
    let network = SupportedNetwork.ethereum
    let mockManager = MockNetworkManagerFactory.createManagers(for: [network])[network]!
    
    // Test concurrent operations
    async let wallet1 = mockManager.connectWallet(.metamask)
    async let wallet2 = mockManager.connectWallet(.walletconnect)
    async let wallet3 = mockManager.connectWallet(.metamask)
    
    let wallets = try await [wallet1, wallet2, wallet3]
    
    // All wallets should be connected successfully
    for wallet in wallets {
        #expect(wallet.isConnected == true)
        #expect(!wallet.address.isEmpty)
    }
    
    // Test concurrent balance queries
    async let balance1 = mockManager.getBalance(address: wallets[0].address, token: nil as String?)
    async let balance2 = mockManager.getBalance(address: wallets[1].address, token: nil as String?)
    async let balance3 = mockManager.getBalance(address: wallets[2].address, token: nil as String?)
    
    let balances = try await [balance1, balance2, balance3]
    
    // All balances should be valid
    for balance in balances {
        #expect(balance >= 0)
    }
}

@Test("MockNetworkManager should handle iPhone 17/17 Pro optimizations")
func testMockNetworkManagerIPhone17Optimizations() async throws {
    let optimizedNetworks: [SupportedNetwork] = [.ethereum, .polygon, .arbitrum, .optimism, .solana, .algorand]
    
    for network in optimizedNetworks {
        let mockManager = MockNetworkManagerFactory.createManagers(for: [network])[network]!
        
        // Test that optimized networks work correctly
        #expect(network.supportsIPhone17Features == true)
        
        let wallets = mockManager.getAvailableWallets()
        #expect(!wallets.isEmpty)
        
        if let firstWallet = wallets.first {
            let connectedWallet = try await mockManager.connectWallet(firstWallet.walletType)
            
            // Test optimized features
            let networkInfo = NetworkInfo.from(network: network)
            #expect(networkInfo.supportsIPhone17Features == true)
            #expect(networkInfo.priority >= 4)
            
            await mockManager.disconnectWallet(connectedWallet)
        }
    }
}
