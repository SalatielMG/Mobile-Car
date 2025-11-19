import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/navigation_command.dart';
import '../providers/app_provider.dart';

/// Widget de controles de navegación circulares
class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final isEnabled = provider.isConnected && provider.isRunning;

        return SizedBox(
          width: 320,
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Botón Adelante (Arriba)
              Positioned(
                top: 0,
                child: _NavigationButton(
                  icon: Icons.arrow_upward,
                  command: NavigationCommand.forward,
                  enabled: isEnabled,
                  onPressed: () => provider.sendNavigationCommand(
                    NavigationCommand.forward.command,
                  ),
                ),
              ),
              // Botón Atrás (Abajo)
              Positioned(
                bottom: 0,
                child: _NavigationButton(
                  icon: Icons.arrow_downward,
                  command: NavigationCommand.backward,
                  enabled: isEnabled,
                  onPressed: () => provider.sendNavigationCommand(
                    NavigationCommand.backward.command,
                  ),
                ),
              ),
              // Botón Izquierda
              Positioned(
                left: 0,
                child: _NavigationButton(
                  icon: Icons.arrow_back,
                  command: NavigationCommand.left,
                  enabled: isEnabled,
                  onPressed: () => provider.sendNavigationCommand(
                    NavigationCommand.left.command,
                  ),
                ),
              ),
              // Botón Derecha
              Positioned(
                right: 0,
                child: _NavigationButton(
                  icon: Icons.arrow_forward,
                  command: NavigationCommand.right,
                  enabled: isEnabled,
                  onPressed: () => provider.sendNavigationCommand(
                    NavigationCommand.right.command,
                  ),
                ),
              ),
              // Botón central Iniciar/Detener
              _StartStopButton(
                isRunning: provider.isRunning,
                isConnected: provider.isConnected,
                onPressed: provider.toggleRunning,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Botón individual de navegación
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final NavigationCommand command;
  final bool enabled;
  final VoidCallback onPressed;

  const _NavigationButton({
    required this.icon,
    required this.command,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(24),
        disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        icon,
        size: 32,
      ),
    );
  }
}

/// Botón central de Iniciar/Detener
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
        disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
