#!/usr/bin/env zsh

# Script para generar el APK de release usando FVM

set -e

# Verificar que fvm esté instalado
command -v fvm >/dev/null 2>&1 || { echo "Error: fvm no encontrado. Asegúrate de tenerlo instalado."; exit 1; }

echo "🧹 Limpiando proyecto..."
fvm flutter clean

echo "📦 Obteniendo dependencias..."
fvm flutter pub get

echo "🔨 Construyendo APK (Release)..."
# Se puede agregar --split-per-abi si se desea reducir el tamaño por arquitectura
fvm flutter build apk --release

echo "✅ Construcción completada exitosamente."
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    echo "📂 El APK se encuentra en: $APK_PATH"
    
    # Intentar abrir la carpeta contenedora (funciona en macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open build/app/outputs/flutter-apk/
    fi
else
    echo "❌ Error: No se encontró el archivo APK generado."
    exit 1
fi
