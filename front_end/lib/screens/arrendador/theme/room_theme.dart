import 'package:flutter/material.dart';

class RoomTheme {
  final String name;
  final String label;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final IconData mainIcon;
  final String emoji;

  const RoomTheme({
    required this.name,
    required this.label,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.mainIcon,
    required this.emoji,
  });
}