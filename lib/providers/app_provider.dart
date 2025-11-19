import 'package:flutter/material.dart';
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
