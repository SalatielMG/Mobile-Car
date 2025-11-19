#!/bin/bash

# Script para agregar namespace al plugin flutter_bluetooth_serial

PLUGIN_PATH="$HOME/.pub-cache/hosted/pub.dev/flutter_bluetooth_serial-0.4.0/android/build.gradle"

if [ -f "$PLUGIN_PATH" ]; then
    echo "Agregando namespace a flutter_bluetooth_serial..."
    
    # Verificar si ya tiene namespace
    if grep -q "namespace" "$PLUGIN_PATH"; then
        echo "✓ El namespace ya existe"
    else
        # Agregar namespace después de apply plugin
        sed -i '' "/apply plugin: 'com.android.library'/a\\
\\
    namespace 'io.github.edufolly.flutterbluetoothserial'
" "$PLUGIN_PATH"
        echo "✓ Namespace agregado exitosamente"
    fi
else
    echo "⚠️  Plugin no encontrado en: $PLUGIN_PATH"
    echo "Ejecuta: flutter pub get"
fi
