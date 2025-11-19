import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bluetooth_devices_modal.dart';
import '../widgets/navigation_controls.dart';

/// Pantalla principal de la aplicación
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Remoto'),
        centerTitle: true,
        leading: Consumer<AppProvider>(
          builder: (context, provider, _) {
            return IconButton(
              icon: Icon(
                provider.isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                color: provider.isConnected ? Colors.green : null,
              ),
              onPressed: () => _showBluetoothDevices(context),
            );
          },
        ),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: Icon(
                  provider.themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: provider.toggleTheme,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Estado de conexión
            Consumer<AppProvider>(
              builder: (context, provider, _) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (provider.isConnected)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.bluetooth_connected,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Conectado: ${provider.connectedDevice!.name}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.bluetooth_disabled,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sin conexión',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Controles de navegación
            const NavigationControls(),
          ],
        ),
      ),
    );
  }

  /// Muestra el modal de dispositivos Bluetooth
  void _showBluetoothDevices(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const BluetoothDevicesModal(),
    );
  }
}
