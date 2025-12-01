#!/usr/bin/env zsh

# Script para actualizar los iconos de la aplicación en Android e iOS

set -e

# Ruta por defecto del icono
DEFAULT_ICON_PATH="assets/app-icon.png"

# Usar el primer parámetro si se proporciona, sino usar el valor por defecto
ICON_PATH="${1:-$DEFAULT_ICON_PATH}"

echo "🔍 Verificando ruta del icono: $ICON_PATH"

# Verificar que el archivo existe
if [ ! -f "$ICON_PATH" ]; then
    echo "❌ Error: No se encontró el archivo de icono en '$ICON_PATH'"
    echo "Uso: ./scripts/update_icons.sh [ruta-del-icono]"
    echo "Ejemplo: ./scripts/update_icons.sh assets/app-icon.png"
    exit 1
fi

# Verificar que fvm esté instalado
command -v fvm >/dev/null 2>&1 || { 
    echo "❌ Error: fvm no encontrado. Asegúrate de tenerlo instalado."; 
    exit 1; 
}

echo "📝 Actualizando configuración en pubspec.yaml..."

# Crear backup temporal del pubspec.yaml
cp pubspec.yaml pubspec.yaml.backup

# Verificar si ya existe la configuración de flutter_launcher_icons
if grep -q "flutter_launcher_icons:" pubspec.yaml; then
    # Actualizar la ruta del icono existente
    sed -i.tmp "s|image_path:.*|image_path: \"$ICON_PATH\"|" pubspec.yaml
    rm -f pubspec.yaml.tmp
    echo "✓ Configuración actualizada"
else
    # Agregar configuración si no existe
    echo "" >> pubspec.yaml
    echo "flutter_launcher_icons:" >> pubspec.yaml
    echo "  android: true" >> pubspec.yaml
    echo "  ios: true" >> pubspec.yaml
    echo "  image_path: \"$ICON_PATH\"" >> pubspec.yaml
    echo "  remove_alpha_ios: true" >> pubspec.yaml
    echo "✓ Configuración agregada"
fi

echo "📦 Obteniendo dependencias..."
fvm flutter pub get > /dev/null 2>&1

echo "🎨 Generando iconos para Android e iOS..."
fvm dart run flutter_launcher_icons

# Restaurar backup
rm -f pubspec.yaml.backup

echo "✅ Iconos actualizados exitosamente desde: $ICON_PATH"
echo ""
echo "Los nuevos iconos se aplicarán al recompilar la aplicación."
