import Testing
import Foundation
import MultichainWalletConnect

// MARK: - Integration Tests for iPhone 17/17 Pro

@Test("All supported networks should have valid configurations")
func testAllNetworksConfiguration() async throws {
    let networks: [SupportedNetwork] = [.ethereum, .bitcoin, .solana, .polygon, .arbitrum, .optimism, .algorand, .ton]
    
    for network in networks {
        let networkInfo = NetworkInfo.from(network: network)
        
        #expect(!networkInfo.name.isEmpty)
        #expect(!networkInfo.chainId.isEmpty)
        #expect(!networkInfo.rpcUrl.isEmpty)
        #expect(!networkInfo.explorerUrl.isEmpty)
        #expect(!networkInfo.nativeToken.isEmpty)
        #expect(networkInfo.decimals > 0)
        #expect(networkInfo.priority > 0)
        #expect(!networkInfo.iconName.isEmpty)
        #expect(!networkInfo.primaryColor.isEmpty)
    }
}

@Test("iPhone 17/17 Pro optimized networks should have correct features")
func testIPhone17OptimizedNetworks() async throws {
    let optimizedNetworks: [SupportedNetwork] = [.ethereum, .polygon, .arbitrum, .optimism, .solana, .algorand]
    
    for network in optimizedNetworks {
        #expect(network.supportsIPhone17Features == true)
        #expect(network.priority >= 4) // Should have decent priority
        
        let networkInfo = NetworkInfo.from(network: network)
        #expect(networkInfo.supportsIPhone17Features == true)
    }
}

@Test("Network performance metrics should be valid")
func testNetworkPerformanceMetrics() async throws {
    let networks: [SupportedNetwork] = [.ethereum, .bitcoin, .solana, .polygon, .arbitrum, .optimism, .algorand, .ton]
    
    for network in networks {
        let metrics = NetworkPerformanceMetrics(network: network)
        
        #expect(metrics.averageBlockTime > 0)
        #expect(metrics.transactionSuccessRate > 0.9) // At least 90% success rate
        #expect(metrics.averageConfirmationTime > 0)
        #expect(metrics.isOptimizedForIPhone17 == network.supportsIPhone17Features)
    }
}

@Test("iPhone 17 network configuration should be valid")
func testIPhone17NetworkConfig() async throws {
    let networks: [SupportedNetwork] = [.ethereum, .bitcoin, .solana, .polygon, .arbitrum, .optimism, .algorand, .ton]
    
    for network in networks {
        let config = iPhone17NetworkConfig.defaultConfig(for: network)
        
        #expect(config.network == network)
        #expect(config.isEnabled == true)
        #expect(config.priority == network.priority)
        #expect(config.supportsAdvancedFeatures == network.supportsIPhone17Features)
        #expect(config.recommendedForIPhone17 == (network.priority >= 7))
    }
}

@Test("Network priority should be correctly ordered")
func testNetworkPriorityOrdering() async throws {
    let networks = SupportedNetwork.allCases.sorted { $0.priority > $1.priority }
    
    #expect(networks[0] == .ethereum) // Highest priority
    #expect(networks[1] == .bitcoin)
    #expect(networks[2] == .solana)
    #expect(networks[3] == .polygon)
    #expect(networks[4] == .arbitrum)
    #expect(networks[5] == .optimism)
    #expect(networks[6] == .algorand)
    #expect(networks[7] == .ton) // Lowest priority
}

@Test("Network colors should be valid hex colors")
func testNetworkColors() async throws {
    let networks: [SupportedNetwork] = [.ethereum, .bitcoin, .solana, .polygon, .arbitrum, .optimism, .algorand, .ton]
    
    for network in networks {
        let color = network.primaryColor
        
        #expect(color.hasPrefix("#"))
        #expect(color.count == 7) // #RRGGBB format
        #expect(color.dropFirst().allSatisfy { $0.isHexDigit })
    }
}

@Test("Network icons should have valid names")
func testNetworkIcons() async throws {
    let networks: [SupportedNetwork] = [.ethereum, .bitcoin, .solana, .polygon, .arbitrum, .optimism, .algorand, .ton]
    
    for network in networks {
        let iconName = network.iconName
        
        #expect(!iconName.isEmpty)
        #expect(iconName.hasSuffix("-icon"))
        #expect(iconName.contains(network.rawValue))
    }
}

@Test("MultichainWalletManager should work with all networks")
func testMultichainWalletManagerAllNetworks() async throws {
    let manager = await MultichainWalletManager.shared
    
    // Test with high-priority networks first
    let priorityNetworks: [SupportedNetwork] = [.ethereum, .solana, .polygon, .arbitrum]
    
    for network in priorityNetworks {
        let wallets = await manager.getAvailableWallets(for: network)
        #expect(!wallets.isEmpty, "No wallets available for \(network.displayName)")
        
        // Test connection if wallets are available
        if let firstWallet = wallets.first {
            let connectedWallet = try await manager.connectWallet(firstWallet.walletType, network: network)
            #expect(connectedWallet.network == network)
            #expect(connectedWallet.isConnected == true)
            
            // Test balance retrieval
            let balance = try await manager.getBalance(for: connectedWallet.address, network: network)
            #expect(balance >= 0)
            
            // Disconnect
            await manager.disconnectWallet(connectedWallet)
        }
    }
}

@Test("Transaction simulation should work across networks")
func testTransactionSimulationAcrossNetworks() async throws {
    let manager = await MultichainWalletManager.shared
    
    // Test with networks that support transactions
    let transactionNetworks: [SupportedNetwork] = [.ethereum, .solana, .polygon, .arbitrum, .optimism]
    
    for network in transactionNetworks {
        let wallets = await manager.getAvailableWallets(for: network)
        guard let firstWallet = wallets.first else { 
            print("⚠️ No wallets available for \(network.displayName), skipping transaction test")
            continue 
        }
        
        // Connect wallet
        let connectedWallet = try await manager.connectWallet(firstWallet.walletType, network: network)
        
        // Create transaction
        let networkInfo = NetworkInfo.from(network: network)
        let transaction = TransactionRequest(
            to: "0x1234567890abcdef1234567890abcdef12345678",
            amount: 0.1,
            token: networkInfo.nativeToken,
            note: "iPhone 17 Integration Test",
            from: connectedWallet.address
        )
        
        // Send transaction
        let txHash = try await manager.sendTransaction(transaction)
        #expect(!txHash.isEmpty)
        
        // Disconnect
        await manager.disconnectWallet(connectedWallet)
    }
}
