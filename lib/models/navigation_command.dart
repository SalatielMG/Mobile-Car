/// Enumeración de comandos de navegación
enum NavigationCommand {
  forward('F', 'Adelante'),
  backward('B', 'Atrás'),
  left('L', 'Izquierda'),
  right('R', 'Derecha'),
  stop('S', 'Detener');

  final String command;
  final String label;

  const NavigationCommand(this.command, this.label);
}
