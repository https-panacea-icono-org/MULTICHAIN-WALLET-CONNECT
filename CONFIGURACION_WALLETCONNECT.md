# Configuración de WalletConnect - PANACEA Ecosystem

## 🔑 IDs de WalletConnect

### Project ID
```
1ceaca1be9a50ff20c416f4b7da95d84
```

### Session ID
```
c05e44f7-8a6e-45ef-be63-438fee9d8676
```

## 🌐 Configuración de Redes (Mainnet)

### TON Mainnet
- **RPC URL**: `https://toncenter.com/api/v2`
- **Explorer**: `https://tonscan.org`
- **Chain ID**: `ton-mainnet`
- **Token Nativo**: TON (9 decimales)

### Algorand Mainnet
- **RPC URL**: `https://mainnet-api.algonode.cloud`
- **Explorer**: `https://algoexplorer.io`
- **Chain ID**: `algorand-mainnet`
- **Token Nativo**: ALGO (6 decimales)

### Solana Mainnet
- **RPC URL**: `https://api.mainnet-beta.solana.com`
- **Explorer**: `https://explorer.solana.com`
- **Chain ID**: `solana-mainnet`
- **Token Nativo**: SOL (9 decimales)

### Ethereum Mainnet
- **RPC URL**: `https://mainnet.infura.io/v3`
- **Explorer**: `https://etherscan.io`
- **Chain ID**: `ethereum-mainnet`
- **Token Nativo**: ETH (18 decimales)

## 🔧 Configuración de WalletConnect

### Bridge URL
```
https://bridge.walletconnect.org
```

### Relay URL
```
wss://relay.walletconnect.org
```

## 📱 Billeteras Soportadas

### TON
- **TONKeeper**: `tonkeeper://`
- **TonWallet**: `tonwallet://`

### Algorand
- **Pera Wallet**: `algorand://`
- **MyAlgo**: `myalgo://`

### Solana
- **Phantom**: `phantom://`
- **Solflare**: `solflare://`

### Ethereum
- **MetaMask**: `metamask://`
- **WalletConnect**: Universal

## 🚀 Uso en Aplicaciones

### Importar el módulo
```swift
import MultichainWalletConnect
```

### Configurar WalletConnect
```swift
let config = WalletConnectConfig.getWalletConnectConfig()
// config.projectId = "1ceaca1be9a50ff20c416f4b7da95d84"
// config.sessionId = "c05e44f7-8a6e-45ef-be63-438fee9d8676"
```

### Conectar billetera
```swift
let walletManager = MultichainWalletManager.shared

// Conectar a TON
await walletManager.connectWallet(.tonkeeper)

// Conectar a Algorand
await walletManager.connectWallet(.pera)

// Conectar a Solana
await walletManager.connectWallet(.phantom)
```

## 🔐 Seguridad

- ✅ Todas las conexiones son a mainnet
- ✅ IDs de WalletConnect configurados
- ✅ URLs de RPC verificadas
- ✅ Deep links seguros
- ✅ Validación de direcciones

## 📊 Estado del Proyecto

- ✅ **MULTICHAIN-WALLET-CONNECT** - Completado
- ✅ **Configuración Mainnet** - Completado
- ✅ **IDs de WalletConnect** - Configurados
- ✅ **Documentación** - Completada
- ✅ **Integración QR** - Completada

---

**Desarrollado por PANACEA Icono S.A. - 2025**
