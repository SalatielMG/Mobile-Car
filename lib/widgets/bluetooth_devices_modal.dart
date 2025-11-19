import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bluetooth_device_model.dart';
import '../providers/app_provider.dart';

/// Modal para listar y conectar dispositivos Bluetooth
class BluetoothDevicesModal extends StatefulWidget {
  const BluetoothDevicesModal({super.key});

  @override
  State<BluetoothDevicesModal> createState() => _BluetoothDevicesModalState();
}

class _BluetoothDevicesModalState extends State<BluetoothDevicesModal> {
  List<BluetoothDeviceModel>? _devices;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = context.read<AppProvider>();

      // Verificar permisos
      final hasPermissions = await provider.checkAndRequestPermissions();
      if (!hasPermissions) {
        throw Exception('Permisos de Bluetooth denegados');
      }

      // Verificar si Bluetooth está habilitado
      final isEnabled = await provider.isBluetoothEnabled();
      if (!isEnabled) {
        final enabled = await provider.enableBluetooth();
        if (!enabled) {
          throw Exception('Bluetooth no habilitado');
        }
      }

      // Obtener dispositivos emparejados
      final devices = await provider.getPairedDevices();
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDeviceModel device) async {
    try {
      setState(() => _isLoading = true);

      final provider = context.read<AppProvider>();
      await provider.connectToDevice(device);

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conectado a ${device.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dispositivos Bluetooth',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          // Contenido
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _loadDevices,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          else if (_devices == null || _devices!.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.bluetooth_disabled, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No se encontraron dispositivos emparejados',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _devices!.length,
                itemBuilder: (context, index) {
                  final device = _devices![index];
                  return Consumer<AppProvider>(
                    builder: (context, provider, _) {
                      final isConnected =
                          provider.connectedDevice?.address == device.address;

                      return ListTile(
                        leading: Icon(
                          isConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth,
                          color: isConnected ? Colors.green : null,
                        ),
                        title: Text(device.name),
                        subtitle: Text(device.address),
                        trailing: isConnected
                            ? FilledButton.tonal(
                                onPressed: () async {
                                  await provider.disconnect();
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Desconectar'),
                              )
                            : FilledButton(
                                onPressed: () => _connectToDevice(device),
                                child: const Text('Conectar'),
                              ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
