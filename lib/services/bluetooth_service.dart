import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/bluetooth_device_model.dart';

/// Servicio para gestionar la conexión y comunicación Bluetooth
/// Compatible con módulos HC-05 y HC-06
class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  BluetoothDeviceModel? _connectedDevice;

  /// Obtiene el dispositivo actualmente conectado
  BluetoothDeviceModel? get connectedDevice => _connectedDevice;

  /// Verifica si hay una conexión activa
  bool get isConnected => _connection != null && _connection!.isConnected;

  /// Solicita permisos de Bluetooth
  Future<bool> requestPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.location.request().isGranted) {
      return true;
    }
    return false;
  }

  /// Verifica si el Bluetooth está habilitado
  Future<bool> isBluetoothEnabled() async {
    return await _bluetooth.isEnabled ?? false;
  }

  /// Habilita el Bluetooth
  Future<bool> enableBluetooth() async {
    return await _bluetooth.requestEnable() ?? false;
  }

  /// Obtiene la lista de dispositivos emparejados
  Future<List<BluetoothDeviceModel>> getPairedDevices() async {
    try {
      final devices = await _bluetooth.getBondedDevices();
      return devices
          .map((device) => BluetoothDeviceModel.fromDevice(device))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener dispositivos emparejados: $e');
    }
  }

  /// Conecta a un dispositivo Bluetooth (HC-05/HC-06)
  Future<bool> connectToDevice(BluetoothDeviceModel device) async {
    try {
      // Desconectar dispositivo previo si existe
      await disconnect();

      // Conectar al nuevo dispositivo
      _connection = await BluetoothConnection.toAddress(device.address);
      _connectedDevice = device;

      return true;
    } catch (e) {
      _connection = null;
      _connectedDevice = null;
      throw Exception('Error al conectar con el dispositivo: $e');
    }
  }

  /// Desconecta el dispositivo actual
  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.finish();
      _connection = null;
      _connectedDevice = null;
    }
  }

  /// Envía un comando al dispositivo conectado (HC-05/HC-06)
  Future<bool> sendCommand(String command) async {
    if (!isConnected) {
      throw Exception('No hay dispositivo conectado');
    }

    try {
      _connection!.output.add(Uint8List.fromList(utf8.encode(command)));
      await _connection!.output.allSent;
      return true;
    } catch (e) {
      throw Exception('Error al enviar comando: $e');
    }
  }

  /// Limpia los recursos al cerrar la aplicación
  void dispose() {
    disconnect();
  }
}
