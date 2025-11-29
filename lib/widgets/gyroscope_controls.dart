import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class GyroscopeControls extends StatefulWidget {
  const GyroscopeControls({super.key});

  @override
  State<GyroscopeControls> createState() => _GyroscopeControlsState();
}

class _GyroscopeControlsState extends State<GyroscopeControls> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initGyroscope();
    });
  }

  Future<void> _initGyroscope() async {
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    final hasPermission = await provider.checkGyroscopePermissions();
    if (hasPermission) {
      provider.setGyroscopeActive(true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se requieren permisos de sensores')),
        );
      }
    }
  }

  @override
  void deactivate() {
    context.read<AppProvider>().setGyroscopeActive(false);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        // Determinar dirección activa basada en x, y
        String activeCommand = 'S';
        final double threshold = provider.gyroscopeThreshold;
        if (provider.y < -threshold) activeCommand = 'F';
        else if (provider.y > threshold) activeCommand = 'B';
        else if (provider.x > threshold) activeCommand = 'L';
        else if (provider.x < -threshold) activeCommand = 'R';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 320,
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Indicadores visuales
                  _GyroIndicator(
                    icon: Icons.arrow_upward,
                    isActive: activeCommand == 'F',
                    alignment: Alignment.topCenter,
                  ),
                  _GyroIndicator(
                    icon: Icons.arrow_downward,
                    isActive: activeCommand == 'B',
                    alignment: Alignment.bottomCenter,
                  ),
                  _GyroIndicator(
                    icon: Icons.arrow_back,
                    isActive: activeCommand == 'L',
                    alignment: Alignment.centerLeft,
                  ),
                  _GyroIndicator(
                    icon: Icons.arrow_forward,
                    isActive: activeCommand == 'R',
                    alignment: Alignment.centerRight,
                  ),
                  
                  // Botón central Play/Stop
                  _StartStopButton(
                    isRunning: provider.isRunning,
                    isConnected: provider.isConnected,
                    onPressed: provider.toggleRunning,
                  ),
                  
                  // Datos de depuración
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Text(
                      'X: ${provider.x.toStringAsFixed(1)}  Y: ${provider.y.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 12, 
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Control de sensibilidad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sensibilidad (Umbral)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        provider.gyroscopeThreshold.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: provider.gyroscopeThreshold,
                    min: 0.5,
                    max: 5.0,
                    divisions: 45,
                    label: provider.gyroscopeThreshold.toStringAsFixed(1),
                    onChanged: (value) {
                      provider.setGyroscopeThreshold(value);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GyroIndicator extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Alignment alignment;

  const _GyroIndicator({
    required this.icon,
    required this.isActive,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          icon,
          size: 32,
          color: isActive 
              ? Theme.of(context).colorScheme.onPrimary 
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _StartStopButton extends StatelessWidget {
  final bool isRunning;
  final bool isConnected;
  final VoidCallback onPressed;

  const _StartStopButton({
    required this.isRunning,
    required this.isConnected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: isConnected ? onPressed : null,
      style: FilledButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(32),
        backgroundColor: isRunning
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      child: Icon(
        isRunning ? Icons.stop : Icons.play_arrow,
        size: 48,
        color: isRunning
            ? Theme.of(context).colorScheme.onError
            : Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
