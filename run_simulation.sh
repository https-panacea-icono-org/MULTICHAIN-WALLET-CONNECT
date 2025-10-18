#!/bin/bash

echo "🚀 Ejecutando simulación de MULTICHAIN-WALLET-CONNECT..."
echo "======================================================"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "Package.swift" ]; then
    echo "❌ Error: No se encontró Package.swift. Asegúrate de estar en el directorio raíz del proyecto."
    exit 1
fi

# Compilar el proyecto principal
echo "🔨 Compilando módulo principal..."
swift build
if [ $? -ne 0 ]; then
    echo "❌ Error: Falló la compilación del módulo principal"
    exit 1
fi

echo "✅ Módulo principal compilado correctamente"
echo ""

# Ejecutar la simulación
echo "🎮 Ejecutando simulación..."
cd SimulationApp
swift run

echo ""
echo "🎉 Simulación completada!"
