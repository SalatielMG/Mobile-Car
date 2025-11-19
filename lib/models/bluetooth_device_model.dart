import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

/// Modelo para representar un dispositivo Bluetooth
class BluetoothDeviceModel {
  final String name;
  final String address;
  final BluetoothDevice device;

  BluetoothDeviceModel({
    required this.name,
    required this.address,
    required this.device,
  });

  factory BluetoothDeviceModel.fromDevice(BluetoothDevice device) {
    return BluetoothDeviceModel(
      name: device.name ?? 'Desconocido',
      address: device.address,
      device: device,
    );
  }
}
