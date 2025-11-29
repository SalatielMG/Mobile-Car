import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InfoModal extends StatefulWidget {
  const InfoModal({super.key});

  @override
  State<InfoModal> createState() => _InfoModalState();
}

class _InfoModalState extends State<InfoModal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final yamlString = await DefaultAssetBundle.of(context).loadString('pubspec.yaml');
      final RegExp versionRegExp = RegExp(r'version:\s*(.+)');
      final match = versionRegExp.firstMatch(yamlString);
      if (match != null && mounted) {
        setState(() {
          _appVersion = match.group(1)?.trim() ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading version: $e');
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoAsset = 'assets/logo.png';
    // final logoAsset = isDark ? 'assets/logo_dark.png' : 'assets/logo_light.png';
    
    // Parse student names
    final rawNames = dotenv.env['STUDENT_NAMES'] ?? 'Nombres no definidos';
    final studentNames = rawNames.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return AlertDialog(
      content: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contenido principal
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation.value),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          logoAsset,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.school,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                if (studentNames.isEmpty)
                  const Text(
                    'Nombres no definidos',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  )
                else
                  ...studentNames.map((name) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: (studentNames.isNotEmpty && studentNames.first == name)
                          ? FontWeight.bold
                          : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  )),
                const SizedBox(height: 12),
                Text(
                  dotenv.env['GRADE_GROUP'] ?? 'Grado y Grupo no definido',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  dotenv.env['CAREER'] ?? 'Carrera no definida',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  dotenv.env['SUBJECT'] ?? 'Materia no definida',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            // Espaciador que empuja la versión al final
            const Spacer(),
            // Versión al final
            if (_appVersion.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Versión: $_appVersion',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
