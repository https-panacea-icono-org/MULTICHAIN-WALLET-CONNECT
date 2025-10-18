# Guía de Integración - Multichain Wallet Connect

## 🚀 Descripción

**Multichain Wallet Connect** es un sistema unificado de conexión de billeteras multichain para el ecosistema PANACEA. Soporta conexión a múltiples redes blockchain incluyendo TON, Algorand, Solana y Ethereum mediante QR y WalletConnect.

## 🏗️ Arquitectura

### Redes Soportadas (Mainnet)
- **TON Mainnet** - TONKeeper, TonWallet
- **Algorand Mainnet** - Pera Wallet, MyAlgo
- **Solana Mainnet** - Phantom, Solflare
- **Ethereum Mainnet** - MetaMask, WalletConnect

### Métodos de Conexión
- **QR Code** - Escaneo directo para billeteras móviles
- **WalletConnect** - Protocolo universal de conexión
- **Deep Links** - Conexión directa a aplicaciones nativas

## 📦 Instalación

### 1. Agregar Dependencias

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panacea-icono/multichain-wallet-connect.git", from: "1.0.0")
]
```

### 2. Configurar Variables de Entorno

```bash
# .env
WALLETCONNECT_PROJECT_ID=your_walletconnect_project_id
APP_NAME=PANACEA Ecosystem
APP_VERSION=1.0.0
API_BASE_URL=https://api.panacea-icono.org
IS_PRODUCTION=false
SUPPORTED_NETWORKS=ton,algorand,solana,ethereum
DEFAULT_NETWORK=algorand
NETWORK_TYPE=mainnet
```

## 🔧 Uso Básico

### Conexión de Wallet

```swift
import MultichainWalletConnect

let walletManager = MultichainWalletManager.shared

// Conectar a TON
await walletManager.connectWallet(.tonkeeper)

// Conectar a Algorand
await walletManager.connectWallet(.pera)

// Conectar a Solana
await walletManager.connectWallet(.phantom)
```

### Conexión con QR

```swift
// Generar QR para conexión
let qrCode = await walletManager.generateConnectionQR(for: .tonkeeper)

// Escanear QR para conectar
let result = await walletManager.scanAndConnect(qrCode: scannedCode)
```

### Envío de Transacciones

```swift
// Enviar transacción
let result = await walletManager.sendTransaction(
    to: "DESTINO_ADDRESS",
    amount: 1.0,
    token: "ALGO",
    note: "Pago de servicios"
)

switch result {
case .success(let hash):
    print("Transacción enviada: \(hash)")
case .failure(let error):
    print("Error: \(error.localizedDescription)")
}
```

### Gestión de Balances

```swift
// Actualizar balances
await walletManager.refreshBalance()

// Obtener balance
let balance = walletManager.getBalance()

// Obtener balance de token específico
let tokenBalance = await walletManager.getBalance(token: "PANAS")
```

## 🎯 Integración por Proyecto

### SCAM-ER-APP

```swift
// El WalletConnectManager ya está integrado
class WalletConnectManager: ObservableObject {
    private let unifiedService = MultichainWalletManager.shared
    
    func connectWallet(_ walletType: WalletType) async {
        try await unifiedService.connectWallet(walletType)
    }
    
    func analyzeTransactionRisk(_ transaction: TransactionRequest) -> RiskAnalysis {
        // Lógica específica de SCAM-ER
    }
}
```

### PANAS-TELEGRAM-MINIAPP

```swift
// El AlgorandWalletManager ya está integrado
class AlgorandWalletManager: ObservableObject {
    private let unifiedService = MultichainWalletManager.shared
    
    func connectWallet(type: String) async {
        guard let walletType = WalletType(rawValue: type.lowercased()) else { return }
        try await unifiedService.connectWallet(walletType)
    }
    
    func sendPanas(to recipient: String, amount: Double) async -> Result<String, AlgorandError> {
        return await sendTransaction(to: recipient, amount: amount, tokenId: "PANAS")
    }
}
```

### PANACEA-CLEAN-PROJECT

```swift
// Usar directamente MultichainWalletManager
let walletManager = MultichainWalletManager.shared

// Conectar wallet
await walletManager.connectWallet(.pera)

// Enviar transacción
let result = await walletManager.sendTransaction(
    to: "DESTINO",
    amount: 1.0,
    token: "ALGO"
)
```

## 🔐 Seguridad

### Mejores Prácticas

1. **Nunca hardcodear claves privadas**
2. **Usar variables de entorno para configuración sensible**
3. **Validar todas las direcciones de wallet**
4. **Implementar timeouts para operaciones de red**
5. **Manejar errores de conexión apropiadamente**

### Validación de Configuración

```swift
let validation = ConfigurationValidator.validate(appConfig)

if !validation.isValid {
    print("Errores de configuración:")
    for error in validation.errors {
        print("- \(error)")
    }
}
```

## 🐛 Debugging

### Logs

```swift
// Habilitar logs detallados
import OSLog

let logger = Logger(subsystem: "com.panacea.multichain", category: "Debug")

// El servicio ya incluye logging automático
// Revisar la consola para mensajes como:
// 🔗 Multichain Wallet Connect initialized
// ✅ Wallet connected: Pera Wallet
// ❌ Error connecting wallet: Connection failed
```

### Manejo de Errores

```swift
do {
    try await walletManager.connectWallet(.pera)
} catch WalletError.notConnected {
    print("No hay wallet conectada")
} catch WalletError.connectionFailed {
    print("Error de conexión")
} catch WalletError.invalidConfiguration {
    print("Configuración inválida")
} catch {
    print("Error desconocido: \(error)")
}
```

## 📊 Monitoreo

### Métricas Disponibles

- Estado de conexión
- Wallets conectadas
- Transacciones enviadas
- Errores de conexión
- Tiempo de respuesta
- Balances actualizados

### Implementación de Métricas

```swift
// El servicio incluye métricas automáticas
// Para métricas personalizadas, extender el servicio:

extension MultichainWalletManager {
    func trackCustomMetric(_ name: String, value: Double) {
        // Implementar tracking personalizado
        print("Métrica: \(name) = \(value)")
    }
}
```

## 🚀 Despliegue

### Configuración de Producción

```swift
let productionConfig = AppConfig(
    appName: "PANACEA Ecosystem",
    appVersion: "1.0.0",
    walletConnectProjectId: "production_project_id",
    apiBaseUrl: "https://api.panacea-icono.org",
    isProduction: true
)

MultichainWalletManager.shared.updateAppConfig(productionConfig)
```

### Variables de Entorno de Producción

```bash
# Producción
WALLETCONNECT_PROJECT_ID=prod_walletconnect_project_id
APP_NAME=PANACEA Ecosystem
API_BASE_URL=https://api.panacea-icono.org
IS_PRODUCTION=true
SUPPORTED_NETWORKS=ton,algorand,solana,ethereum
DEFAULT_NETWORK=algorand
NETWORK_TYPE=mainnet
```

## 📚 Referencias

### Documentación Adicional

- [WalletConnect Swift SDK](https://docs.walletconnect.com/swift)
- [Algorand Swift SDK](https://github.com/algorand/swift-algorand-sdk)
- [PANACEA Ecosystem Docs](https://docs.panacea-icono.org)

### Soporte

- **Email**: dev@panacea-icono.org
- **Discord**: [PANACEA Community](https://discord.gg/panacea)
- **GitHub**: [Issues](https://github.com/panacea-icono/multichain-wallet-connect/issues)

## 🔄 Actualizaciones

### Versión 1.0.0
- ✅ Sistema unificado de conexión multichain
- ✅ Soporte para TON, Algorand, Solana, Ethereum
- ✅ Integración con TONKeeper, Pera, Phantom, MetaMask
- ✅ Sistema de QR para conexión móvil
- ✅ WalletConnect universal
- ✅ Arquitectura modular y extensible

### Próximas Versiones
- 🔄 Soporte para más blockchains
- 🔄 Integración con DeFi protocols
- 🔄 Sistema de notificaciones push
- 🔄 Analytics avanzados
- 🔄 Multi-signature wallets

---

**Desarrollado por PANACEA Icono S.A. - 2025**
