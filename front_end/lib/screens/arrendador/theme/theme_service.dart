import 'package:front_end/screens/arrendador/theme/room_theme.dart';

import 'theme_builders.dart';

class ThemeService {
  static RoomTheme getTheme(String themeName) {
    switch (themeName) {
      case 'mecatronica':
        return MecatronicaThemeBuilder().build();
      case 'programacion':
        return ProgramacionThemeBuilder().build();
      case 'electronica':
        return ElectronicaThemeBuilder().build();
      case 'industrial':
        return IndustrialThemeBuilder().build();
      default:
        return EstandarThemeBuilder().build();
    }
  }

  static List<Map<String, dynamic>> getAvailableThemes() {
    return [
      {'value': 'estandar', 'label': 'Estándar', 'emoji': '🏠'},
      {'value': 'mecatronica', 'label': 'Mecatrónica', 'emoji': '⚙️'},
      {'value': 'programacion', 'label': 'Programación', 'emoji': '💻'},
      {'value': 'electronica', 'label': 'Electrónica', 'emoji': '🔌'},
      {'value': 'industrial', 'label': 'Industrial', 'emoji': '🏭'},
    ];
  }
}