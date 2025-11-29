import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/bluetooth_device_model.dart';
import '../services/bluetooth_service.dart';

/// Provider para gestionar el estado de la aplicación
class AppProvider extends ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();

  // Estado del tema
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  // Estado de Bluetooth
  BluetoothDeviceModel? _connectedDevice;
  BluetoothDeviceModel? get connectedDevice => _connectedDevice;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  bool get isConnected => _connectedDevice != null;

  // Estado del Giroscopio
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isGyroscopeActive = false;
  bool get isGyroscopeActive => _isGyroscopeActive;
  String _lastGyroCommand = 'C';
  
  // Valores del acelerómetro para visualización
  double _x = 0, _y = 0;
  double get x => _x;
  double get y => _y;

  // Sensibilidad del giroscopio (Umbral)
  double _gyroscopeThreshold = 2.0;
  double get gyroscopeThreshold => _gyroscopeThreshold;

  /// Establece el umbral de sensibilidad del giroscopio
  void setGyroscopeThreshold(double value) {
    _gyroscopeThreshold = value;
    notifyListeners();
  }

  /// Alterna entre tema claro y oscuro
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Verifica y solicita permisos de Bluetooth
  Future<bool> checkAndRequestPermissions() async {
    return await _bluetoothService.requestPermissions();
  }
  
  /// Verifica permisos de sensores (Giroscopio)
  Future<bool> checkGyroscopePermissions() async {
    if (Platform.isAndroid) {
      // En Android, el acelerómetro/giroscopio estándar no requiere permisos de tiempo de ejecución.
      // Permission.sensors solicita BODY_SENSORS (ritmo cardíaco, etc.), lo cual no necesitamos.
      return true;
    }

    // En iOS sí se requiere permiso (Motion Usage)
    var status = await Permission.sensors.status;
    if (!status.isGranted) {
      status = await Permission.sensors.request();
    }
    return status.isGranted;
  }

  /// Activa/Desactiva el control por giroscopio
  void setGyroscopeActive(bool active) {
    if (_isGyroscopeActive == active) return;
    
    _isGyroscopeActive = active;
    if (active) {
      _startGyroscope();
    } else {
      _stopGyroscope();
    }
    notifyListeners();
  }

  void _startGyroscope() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      _x = event.x;
      _y = event.y;
      notifyListeners(); // Para actualizar UI del giroscopio
      
      if (!_isRunning || !isConnected) return;
      _processAccelerometerData(event);
    });
  }

  void _stopGyroscope() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    if (_isRunning && isConnected) {
      // sendNavigationCommand('S');
    }
  }

  void _processAccelerometerData(AccelerometerEvent event) {
    // Lógica simple de inclinación
    // Ajustar umbrales según sea necesario
    String newCommand = 'C';
    
    // Umbral de sensibilidad dinámico
    final double threshold = _gyroscopeThreshold;

    if (event.y < -threshold) {
      newCommand = 'F'; // Inclinado hacia adelante (top down)
    } else if (event.y > threshold) {
      newCommand = 'B'; // Inclinado hacia atrás (top up)
    } else if (event.x > threshold) {
      newCommand = 'L'; // Inclinado a la izquierda
    } else if (event.x < -threshold) {
      newCommand = 'R'; // Inclinado a la derecha
    }

    if (newCommand != _lastGyroCommand) {
      _lastGyroCommand = newCommand;
      if (_lastGyroCommand != 'C')
        sendNavigationCommand(newCommand);
    }
  }

  /// Verifica si el Bluetooth está habilitado

  /// Verifica si el Bluetooth está habilitado
  Future<bool> isBluetoothEnabled() async {
    return await _bluetoothService.isBluetoothEnabled();
  }

  /// Habilita el Bluetooth
  Future<bool> enableBluetooth() async {
    return await _bluetoothService.enableBluetooth();
  }

  /// Obtiene la lista de dispositivos emparejados
  Future<List<BluetoothDeviceModel>> getPairedDevices() async {
    return await _bluetoothService.getPairedDevices();
  }

  /// Conecta a un dispositivo Bluetooth
  Future<bool> connectToDevice(BluetoothDeviceModel device) async {
    try {
      final success = await _bluetoothService.connectToDevice(device);
      if (success) {
        _connectedDevice = device;
        notifyListeners();
      }
      return success;
    } catch (e) {
      rethrow;
    }
  }

  /// Desconecta el dispositivo actual
  Future<void> disconnect() async {
    await _bluetoothService.disconnect();
    _connectedDevice = null;
    _isRunning = false;
    notifyListeners();
  }

  /// Envía un comando de navegación
  Future<void> sendNavigationCommand(String command) async {
    print('Sending command: $command');
    if (!isConnected) return;

    try {
      await _bluetoothService.sendCommand(command);
    } catch (e) {
      rethrow;
    }
  }

  /// Alterna el estado de inicio/detención
  Future<void> toggleRunning() async {
    if (!isConnected) return;

    _isRunning = !_isRunning;
    notifyListeners();

    // Enviar comando de inicio o detención
    if (!_isRunning) {
      await sendNavigationCommand('S'); // Stop
    }
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
    super.dispose();
  }
}
