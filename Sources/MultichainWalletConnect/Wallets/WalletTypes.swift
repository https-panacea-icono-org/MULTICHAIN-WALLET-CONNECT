// MARK: - Wallet Types and Definitions
// This file contains wallet type definitions and their configurations

import Foundation

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Wallet Types

public enum WalletType: String, CaseIterable, Codable, Sendable {
    case tonkeeper = "tonkeeper"
    case tonwallet = "tonwallet"
    case pera = "pera"
    case myalgo = "myalgo"
    case phantom = "phantom"
    case solflare = "solflare"
    case metamask = "metamask"
    case walletconnect = "walletconnect"
    
    public var displayName: String {
        switch self {
        case .tonkeeper: return "TONKeeper"
        case .tonwallet: return "TON Wallet"
        case .pera: return "Pera Wallet"
        case .myalgo: return "MyAlgo"
        case .phantom: return "Phantom"
        case .solflare: return "Solflare"
        case .metamask: return "MetaMask"
        case .walletconnect: return "WalletConnect"
        }
    }
    
    public var iconName: String {
        switch self {
        case .tonkeeper: return "tonkeeper-icon"
        case .tonwallet: return "tonwallet-icon"
        case .pera: return "pera-icon"
        case .myalgo: return "myalgo-icon"
        case .phantom: return "phantom-icon"
        case .solflare: return "solflare-icon"
        case .metamask: return "metamask-icon"
        case .walletconnect: return "walletconnect-icon"
        }
    }
    
    public var isInstalled: Bool {
        #if canImport(UIKit)
        switch self {
        case .tonkeeper:
            return UIApplication.shared.canOpenURL(URL(string: "tonkeeper://")!)
        case .tonwallet:
            return UIApplication.shared.canOpenURL(URL(string: "tonwallet://")!)
        case .pera:
            return UIApplication.shared.canOpenURL(URL(string: "algorand://")!)
        case .myalgo:
            return UIApplication.shared.canOpenURL(URL(string: "myalgo://")!)
        case .phantom:
            return UIApplication.shared.canOpenURL(URL(string: "phantom://")!)
        case .solflare:
            return UIApplication.shared.canOpenURL(URL(string: "solflare://")!)
        case .metamask:
            return UIApplication.shared.canOpenURL(URL(string: "metamask://")!)
        case .walletconnect:
            return true // WalletConnect es universal
        }
        #else
        return true // En macOS, asumimos que están disponibles
        #endif
    }
    
    public var supportedNetworks: [SupportedNetwork] {
        switch self {
        case .tonkeeper, .tonwallet:
            return [.ton]
        case .pera, .myalgo:
            return [.algorand]
        case .phantom, .solflare:
            return [.solana]
        case .metamask:
            return [.ethereum]
        case .walletconnect:
            return SupportedNetwork.allCases // WalletConnect soporta todas
        }
    }
    
    public var deepLinkScheme: String {
        switch self {
        case .tonkeeper: return "tonkeeper://"
        case .tonwallet: return "tonwallet://"
        case .pera: return "algorand://"
        case .myalgo: return "myalgo://"
        case .phantom: return "phantom://"
        case .solflare: return "solflare://"
        case .metamask: return "metamask://"
        case .walletconnect: return "walletconnect://"
        }
    }
}
