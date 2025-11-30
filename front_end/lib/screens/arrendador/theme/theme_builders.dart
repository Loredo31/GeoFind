import 'room_theme.dart';
import 'package:flutter/material.dart';

abstract class ThemeBuilder {
  RoomTheme build();
}

class EstandarThemeBuilder implements ThemeBuilder {
  @override
  RoomTheme build() {
    return RoomTheme(
      name: 'estandar',
      label: 'Estándar',
      primaryColor: Colors.green[700]!,
      secondaryColor: Colors.green[500]!,
      backgroundColor: Colors.green[50]!,
      cardColor: Colors.white,
      textColor: Colors.green[800]!,
      mainIcon: Icons.home,
      emoji: '🏠',
    );
  }
}

class MecatronicaThemeBuilder implements ThemeBuilder {
  @override
  RoomTheme build() {
    return RoomTheme(
      name: 'mecatronica',
      label: 'Mecatrónica',
      primaryColor: Colors.blue[800]!,
      secondaryColor: Colors.blue[500]!,
      backgroundColor: Colors.blue[50]!,
      cardColor: Colors.white,
      textColor: Colors.blue[900]!,
      mainIcon: Icons.build,
      emoji: '⚙️',
    );
  }
}

class ProgramacionThemeBuilder implements ThemeBuilder {
  @override
  RoomTheme build() {
    return RoomTheme(
      name: 'programacion',
      label: 'Programación',
      primaryColor: Colors.purple[700]!,
      secondaryColor: Colors.purple[500]!,
      backgroundColor: Colors.purple[50]!,
      cardColor: Colors.white,
      textColor: Colors.purple[900]!,
      mainIcon: Icons.code,
      emoji: '💻',
    );
  }
}

class ElectronicaThemeBuilder implements ThemeBuilder {
  @override
  RoomTheme build() {
    return RoomTheme(
      name: 'electronica',
      label: 'Electrónica',
      primaryColor: Colors.orange[700]!,
      secondaryColor: Colors.orange[500]!,
      backgroundColor: Colors.orange[50]!,
      cardColor: Colors.white,
      textColor: Colors.orange[900]!,
      mainIcon: Icons.electrical_services,
      emoji: '🔌',
    );
  }
}

class IndustrialThemeBuilder implements ThemeBuilder {
  @override
  RoomTheme build() {
    return RoomTheme(
      name: 'industrial',
      label: 'Industrial',
      primaryColor: Colors.red[700]!,
      secondaryColor: Colors.red[500]!,
      backgroundColor: Colors.red[50]!,
      cardColor: Colors.white,
      textColor: Colors.red[900]!,
      mainIcon: Icons.engineering,
      emoji: '🏭',
    );
  }
}