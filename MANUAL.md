# Control Remoto Bluetooth - Mobile Car

Aplicación Flutter de control remoto para módulos Bluetooth **HC-05 y HC-06** (Arduino, ESP32, etc.)

## 🚀 Características

- ✅ **Compatible con HC-05 y HC-06**: Bluetooth clásico SPP
- ✅ **Controles de navegación circulares**: Adelante, Atrás, Izquierda, Derecha
- ✅ **Botón central Start/Stop**: Control para iniciar/detener el dispositivo
- ✅ **Conexión Bluetooth**: Lista y conecta dispositivos Bluetooth emparejados
- ✅ **Tema Dark/Light**: Cambio de tema en tiempo real
- ✅ **Material Design 3**: UI moderna y responsiva
- ✅ **Gestión de estado con Provider**: Arquitectura escalable

## 📋 Requisitos

- Flutter 3.7.2 o superior
- Dart 3.0 o superior
- Android SDK (minSdk 21)
- Dispositivo físico Android (Bluetooth no funciona en emuladores)

## 🛠️ Instalación

1. Clonar el repositorio
2. Instalar dependencias:

```bash
fvm flutter pub get
```

## 🎮 Comandos de Navegación

La aplicación envía los siguientes caracteres al dispositivo Bluetooth:

- **F**: Forward (Adelante)
- **B**: Backward (Atrás)
- **L**: Left (Izquierda)
- **R**: Right (Derecha)
- **S**: Stop (Detener)

## 📱 Uso

1. **Emparejar dispositivo**: Antes de usar la app, empareja tu dispositivo Bluetooth desde la configuración de Android
2. **Abrir app**: Ejecuta la aplicación
3. **Conectar**: Toca el ícono de Bluetooth en la esquina superior izquierda
4. **Seleccionar dispositivo**: Elige tu dispositivo de la lista
5. **Iniciar**: Presiona el botón central para activar los controles
6. **Controlar**: Usa los botones direccionales para controlar tu dispositivo

## 🏗️ Arquitectura

```
lib/
├── main.dart                           # Punto de entrada
├── models/                             # Modelos de datos
│   ├── bluetooth_device_model.dart
│   └── navigation_command.dart
├── services/                           # Lógica de negocio
│   └── bluetooth_service.dart
├── providers/                          # Gestión de estado
│   └── app_provider.dart
├── screens/                            # Pantallas
│   └── home_screen.dart
└── widgets/                            # Componentes reutilizables
    ├── bluetooth_devices_modal.dart
    └── navigation_controls.dart
```

## 🔧 Configuración Arduino con HC-05/HC-06

### Conexiones:
```
HC-05/HC-06 → Arduino
VCC → 5V (o 3.3V según módulo)
GND → GND
TXD → RX (Pin 0)
RXD → TX (Pin 1)
```

### Código Arduino básico:

```cpp
// Control de motor con HC-05/HC-06
// Baudios: 9600 (HC-05/HC-06 por defecto)

void setup() {
  Serial.begin(9600); // Velocidad del HC-05/HC-06
  
  // Configurar pines de motor (ejemplo)
  pinMode(5, OUTPUT);  // Motor izquierdo adelante
  pinMode(6, OUTPUT);  // Motor izquierdo atrás
  pinMode(9, OUTPUT);  // Motor derecho adelante
  pinMode(10, OUTPUT); // Motor derecho atrás
}

void loop() {
  if (Serial.available() > 0) {
    char command = Serial.read();
    
    switch(command) {
      case 'F': // Adelante
        digitalWrite(5, HIGH);
        digitalWrite(9, HIGH);
        digitalWrite(6, LOW);
        digitalWrite(10, LOW);
        break;
        
      case 'B': // Atrás
        digitalWrite(5, LOW);
        digitalWrite(9, LOW);
        digitalWrite(6, HIGH);
        digitalWrite(10, HIGH);
        break;
        
      case 'L': // Izquierda
        digitalWrite(5, LOW);
        digitalWrite(9, HIGH);
        digitalWrite(6, HIGH);
        digitalWrite(10, LOW);
        break;
        
      case 'R': // Derecha
        digitalWrite(5, HIGH);
        digitalWrite(9, LOW);
        digitalWrite(6, LOW);
        digitalWrite(10, HIGH);
        break;
        
      case 'S': // Detener
        digitalWrite(5, LOW);
        digitalWrite(6, LOW);
        digitalWrite(9, LOW);
        digitalWrite(10, LOW);
        break;
    }
  }
}
```

### Configuración HC-05/HC-06:

**Baudios por defecto**: 9600
**PIN por defecto**: 1234 o 0000

Para emparejar:
1. Enciende el módulo HC-05/HC-06
2. En tu Android, ve a Ajustes → Bluetooth
3. Busca "HC-05" o "HC-06"
4. Empareja con PIN: 1234 o 0000
```

## 📦 Dependencias

- `provider: ^6.1.2` - Gestión de estado
- `flutter_bluetooth_serial: ^0.4.0` - Comunicación Bluetooth HC-05/HC-06
- `permission_handler: ^11.3.1` - Manejo de permisos

## ⚙️ Tecnologías Compatibles

- ✅ **HC-05** - Módulo Bluetooth clásico
- ✅ **HC-06** - Módulo Bluetooth clásico
- ✅ **Cualquier dispositivo Bluetooth SPP (Serial Port Profile)**

## 🎨 Temas

La aplicación soporta tema claro y oscuro con Material 3. Cambia entre temas tocando el ícono en la esquina superior derecha.

## 📝 Notas

- Los controles de navegación están deshabilitados hasta que:
  1. Se conecte un dispositivo Bluetooth
  2. Se presione el botón de Start
- La aplicación solo funciona en dispositivos físicos Android (no en emuladores)
- Asegúrate de tener los permisos de Bluetooth y ubicación habilitados
- **Importante**: Debes emparejar el HC-05/HC-06 desde los ajustes de Android **ANTES** de usar la app

## 🐛 Solución de problemas

### No aparecen dispositivos
- Verifica que el Bluetooth esté encendido
- **Asegúrate de haber emparejado el HC-05/HC-06 desde Ajustes de Android primero**
- Concede los permisos de ubicación y Bluetooth
- El LED del HC-05/HC-06 debe estar parpadeando rápido (modo emparejamiento)

### No se conecta
- Verifica que el HC-05/HC-06 esté encendido (LED parpadeando)
- Verifica las conexiones: VCC, GND, TX, RX
- Intenta emparejar el dispositivo nuevamente desde Ajustes de Android
- PIN por defecto: 1234 o 0000
- Reinicia el Bluetooth de tu teléfono

### Los comandos no funcionan
- Verifica que Arduino esté usando `Serial.begin(9600)`
- Comprueba las conexiones TX/RX (pueden estar invertidas)
- Verifica el código Arduino con Serial Monitor primero
- Presiona el botón de Start antes de usar los controles

## 📄 Licencia

Este proyecto es de código abierto.
