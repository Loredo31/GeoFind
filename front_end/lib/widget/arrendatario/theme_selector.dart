// import 'package:flutter/material.dart';
// //import 'package:../screens/arrendatario/theme/theme_service.dart';
// import 'package:front_end/screens/arrendatario/theme/theme_service.dart';

// class ThemeSelector extends StatelessWidget {
//   final String? selectedTheme;
//   final ValueChanged<String?> onThemeChanged;
//   final String? Function(String?)? validator;

//   const ThemeSelector({
//     Key? key,
//     required this.selectedTheme,
//     required this.onThemeChanged,
//     this.validator,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final themes = ThemeService.getAvailableThemes();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Diseño de la habitación',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.green[800],
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           'Elige un diseño que represente el estilo de tu habitación',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.green[600],
//           ),
//         ),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: selectedTheme ?? 'estandar',
//           items: themes.map((theme) {
//             return DropdownMenuItem(
//               value: theme['value'],
//               child: Row(
//                 children: [
//                   Text(theme['emoji']),
//                   const SizedBox(width: 8),
//                   Text(theme['label']),
//                 ],
//               ),
//             );
//           }).toList(),
//           onChanged: onThemeChanged,
//           validator: validator,
//           decoration: InputDecoration(
//             prefixIcon: Icon(Icons.palette, color: Colors.green[700]),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.green[300]!),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.green[500]!, width: 2),
//             ),
//             filled: true,
//             fillColor: Colors.green[50],
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           ),
//           dropdownColor: Colors.green[50],
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:front_end/screens/arrendador/theme/theme_service.dart';

class ThemeSelector extends StatelessWidget {
  final String? selectedTheme;
  final ValueChanged<String?> onThemeChanged;
  final String? Function(String?)? validator;

  const ThemeSelector({
    Key? key,
    required this.selectedTheme,
    required this.onThemeChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themes = ThemeService.getAvailableThemes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diseño de la habitación',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.green[800],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Elige un diseño que represente el estilo de tu habitación',
          style: TextStyle(
            fontSize: 12,
            color: Colors.green[600],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedTheme ?? 'estandar',
          items: themes.map<DropdownMenuItem<String>>((theme) {
            return DropdownMenuItem<String>(
              value: theme['value'] as String, // ✅ Especificar tipo
              child: Row(
                children: [
                  Text(theme['emoji'] as String), // ✅ Especificar tipo
                  const SizedBox(width: 8),
                  Text(theme['label'] as String), // ✅ Especificar tipo
                ],
              ),
            );
          }).toList(),
          onChanged: onThemeChanged,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.palette, color: Colors.green[700]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green[500]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.green[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          dropdownColor: Colors.green[50],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}