# Arquitectura del Proyecto MULTICHAIN-WALLET-CONNECT

## 📁 Estructura del Proyecto

```
MULTICHAIN-WALLET-CONNECT/
├── Sources/
│   └── MultichainWalletConnect/
│       ├── Core/
│       │   ├── Models.swift              # Modelos de datos principales
│       │   └── Configuration.swift       # Gestión de configuración
│       ├── Networks/
│       │   └── NetworkDefinitions.swift  # Definiciones de redes blockchain
│       ├── Wallets/
│       │   └── WalletTypes.swift         # Tipos de billeteras soportadas
│       ├── Managers/
│       │   └── MultichainWalletManager.swift # Gestor principal de billeteras
│       ├── Protocols/
│       │   └── Protocols.swift           # Protocolos y contratos
│       ├── Utils/
│       │   ├── QRCodeGenerator.swift     # Generación de códigos QR
│       │   └── MockNetworkManager.swift  # Implementación mock para testing
│       └── MultichainWalletConnect.swift # Punto de entrada principal
├── Tests/
│   └── MultichainWalletConnectTests/
│       ├── Unit/                         # Tests unitarios
│       ├── Integration/                  # Tests de integración
│       └── Mocks/                        # Mocks y helpers de testing
├── Package.swift                         # Configuración del paquete Swift
└── CONFIGURACION_WALLETCONNECT.md       # Documentación de configuración
```

## 🏗️ Arquitectura Modular

### Core Module
- **Models.swift**: Contiene las estructuras de datos fundamentales como `WalletInfo`, `TransactionRequest`, `WalletError`
- **Configuration.swift**: Maneja la configuración de WalletConnect, redes y variables de entorno

### Networks Module
- **NetworkDefinitions.swift**: Define las redes blockchain soportadas (TON, Algorand, Solana, Ethereum) con sus configuraciones

### Wallets Module
- **WalletTypes.swift**: Define los tipos de billeteras soportadas con sus deep links y configuraciones

### Managers Module
- **MultichainWalletManager.swift**: El gestor principal que coordina todas las operaciones de billeteras

### Protocols Module
- **Protocols.swift**: Define los protocolos que deben implementar los gestores de red

### Utils Module
- **QRCodeGenerator.swift**: Utilidad para generar códigos QR de conexión
- **MockNetworkManager.swift**: Implementación mock para testing y demos

## 🔧 Configuración

### WalletConnect IDs
- **Project ID**: `1ceaca1be9a50ff20c416f4b7da95d84`
- **Session ID**: `c05e44f7-8a6e-45ef-be63-438fee9d8676`

### Redes Soportadas
- **TON**: `https://toncenter.com/api/v2`
- **Algorand**: `https://mainnet-api.algonode.cloud`
- **Solana**: `https://api.mainnet-beta.solana.com`
- **Ethereum**: `https://mainnet.infura.io/v3`

## 🚀 Uso

```swift
import MultichainWalletConnect

// Obtener el gestor de billeteras
let walletManager = MultichainWalletManager.shared

// Conectar a una billetera
let wallet = try await walletManager.connectWallet(.metamask, network: .ethereum)

// Enviar transacción
let transaction = TransactionRequest(
    to: "0x1234...",
    amount: 1.0,
    token: "ETH",
    from: wallet.address
)
let txHash = try await walletManager.sendTransaction(transaction)
```

## 🧪 Testing

El proyecto incluye una implementación mock completa que permite:
- Simular conexiones de billeteras
- Generar balances ficticios
- Simular envío de transacciones
- Testing sin dependencias externas

## 📱 Compatibilidad

- **iOS**: 15.0+
- **macOS**: 12.0+
- **Swift**: 5.9+

## 🔒 Seguridad

- Todas las conexiones son a mainnet
- IDs de WalletConnect configurados
- URLs de RPC verificadas
- Deep links seguros
- Validación de direcciones

---

**Desarrollado por PANACEA Icono S.A. - 2025**
