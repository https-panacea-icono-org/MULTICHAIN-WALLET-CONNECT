# MULTICHAIN WALLET CONNECT

## 🚀 Descripción

Sistema unificado de conexión de billeteras multichain para el ecosistema PANACEA. Soporta conexión a múltiples redes blockchain incluyendo TON, Algorand, Solana y futuras redes mediante QR y WalletConnect.

## 🏗️ Arquitectura

### Redes Soportadas (Mainnet)
- **TON Mainnet** - TONKeeper, TonWallet
- **Algorand Mainnet** - Pera Wallet, MyAlgo
- **Solana Mainnet** - Phantom, Solflare
- **Ethereum Mainnet** - MetaMask, WalletConnect
- **Futuras redes** - Arquitectura extensible

### Métodos de Conexión
- **QR Code** - Escaneo directo para billeteras móviles
- **WalletConnect** - Protocolo universal de conexión
- **Deep Links** - Conexión directa a aplicaciones nativas

## 📁 Estructura del Proyecto

```
MULTICHAIN-WALLET-CONNECT/
├── Sources/
│   ├── Core/
│   │   ├── MultichainWalletManager.swift
│   │   ├── WalletConnectProtocol.swift
│   │   └── NetworkManager.swift
│   ├── Networks/
│   │   ├── TON/
│   │   ├── Algorand/
│   │   ├── Solana/
│   │   └── Ethereum/
│   ├── Wallets/
│   │   ├── TONKeeper/
│   │   ├── PeraWallet/
│   │   ├── Phantom/
│   │   └── MetaMask/
│   ├── QR/
│   │   ├── QRCodeGenerator.swift
│   │   └── QRCodeScanner.swift
│   └── Utils/
│       ├── NetworkConfig.swift
│       └── WalletModels.swift
├── Tests/
├── Package.swift
└── README.md
```

## 🔧 Características Principales

### ✅ Implementado
- Arquitectura modular y extensible
- Soporte para múltiples redes blockchain
- Sistema de QR para conexión móvil
- Integración con WalletConnect
- Gestión unificada de billeteras

### 🚧 En Desarrollo
- Integración específica con TONKeeper
- Conexión directa con Pera Wallet
- Soporte completo para Phantom Wallet
- Sistema de notificaciones push
- Analytics y métricas de uso

## 🚀 Instalación

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panacea-icono/multichain-wallet-connect.git", from: "1.0.0")
]
```

## 📖 Uso

### Conexión Básica

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

## 🔐 Seguridad

- Validación de direcciones de wallet
- Verificación de firmas de transacciones
- Manejo seguro de claves privadas
- Timeouts para operaciones de red
- Logging de auditoría

## 📊 Monitoreo

- Estado de conexión en tiempo real
- Métricas de uso por red
- Errores y excepciones
- Performance de conexiones
- Análisis de transacciones

## 🤝 Contribución

Este proyecto es parte del ecosistema PANACEA Icono S.A. Para contribuir:

1. Fork del repositorio
2. Crear feature branch
3. Implementar cambios
4. Crear Pull Request

## 📄 Licencia

Copyright © 2025 PANACEA Icono S.A. Todos los derechos reservados.

---

**Desarrollado por PANACEA Icono S.A. - 2025**
