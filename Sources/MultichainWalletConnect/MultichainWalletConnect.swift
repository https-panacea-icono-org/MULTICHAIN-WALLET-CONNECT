// MARK: - MultichainWalletConnect Module Entry Point
// This file serves as the main entry point for the MultichainWalletConnect SDK

import Foundation
import Combine
import SwiftUI

// MARK: - Public API Documentation

/**
 # MultichainWalletConnect SDK
 
 A comprehensive Swift SDK for connecting to multiple blockchain networks and wallets.
 
 ## Supported Networks
 - **TON**: TONKeeper, TonWallet
 - **Algorand**: Pera Wallet, MyAlgo
 - **Solana**: Phantom, Solflare
 - **Ethereum**: MetaMask, WalletConnect
 
 ## Quick Start
 
 ```swift
 import MultichainWalletConnect
 
 // Get the shared wallet manager
 let walletManager = MultichainWalletManager.shared
 
 // Connect to a wallet
 let wallet = try await walletManager.connectWallet(.metamask, network: .ethereum)
 
 // Send a transaction
 let transaction = TransactionRequest(
     to: "0x1234...",
     amount: 1.0,
     token: "ETH",
     from: wallet.address
 )
 let txHash = try await walletManager.sendTransaction(transaction)
 ```
 
 ## Configuration
 
 The SDK uses the following WalletConnect configuration:
 - Project ID: `1ceaca1be9a50ff20c416f4b7da95d84`
 - Session ID: `c05e44f7-8a6e-45ef-be63-438fee9d8676`
 
 ## Architecture
 
 The SDK is organized into the following modules:
 - **Core**: Models, Configuration
 - **Networks**: Network definitions and configurations
 - **Wallets**: Wallet type definitions
 - **Managers**: Wallet management logic
 - **Protocols**: Protocol definitions
 - **Utils**: Utilities like QR code generation and mock implementations
 */
