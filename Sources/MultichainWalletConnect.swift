// MARK: - MultichainWalletConnect Module Entry Point

import Foundation
import Combine
import SwiftUI

// Re-exportar todos los tipos públicos del módulo
// Este archivo actúa como el punto de entrada principal

// Los tipos están definidos en los archivos individuales:
// - SharedTypes.swift: Tipos básicos (WalletInfo, SupportedNetwork, etc.)
// - MultichainWalletManager.swift: Gestor principal
// - WalletConnectConfig.swift: Configuración de WalletConnect
// - QRCodeGenerator.swift: Generación de QR
// - TONNetworkManager.swift: Gestor de red TON
// - AlgorandNetworkManager.swift: Gestor de red Algorand
// - SolanaNetworkManager.swift: Gestor de red Solana
// - EthereumNetworkManager.swift: Gestor de red Ethereum
// - TONKeeperWallet.swift: Implementación específica de TONKeeper

// Para usar el módulo, importar directamente:
// import MultichainWalletConnect
// let manager = MultichainWalletManager.shared

// Configuración de WalletConnect:
// Project ID: 1ceaca1be9a50ff20c416f4b7da95d84
// Session ID: c05e44f7-8a6e-45ef-be63-438fee9d8676
