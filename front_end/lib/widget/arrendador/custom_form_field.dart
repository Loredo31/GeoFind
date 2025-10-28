// import 'package:flutter/material.dart';

// class CustomFormField extends StatelessWidget {
//   final TextEditingController controller;
//   final String labelText;
//   final IconData prefixIcon;
//   final TextInputType keyboardType;
//   final int maxLines;
//   final String? Function(String?)? validator;
//   final bool enabled;

//   const CustomFormField({
//     Key? key,
//     required this.controller,
//     required this.labelText,
//     required this.prefixIcon,
//     this.keyboardType = TextInputType.text,
//     this.maxLines = 1,
//     this.validator,
//     this.enabled = true,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           labelText,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Colors.green[800],
//           ),
//         ),
//         const SizedBox(height: 6),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           maxLines: maxLines,
//           enabled: enabled,
//           validator: validator,
//           decoration: InputDecoration(
//             prefixIcon: Icon(prefixIcon, color: Colors.green[700]),
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
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
// }



import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool enabled;

  const CustomFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ← ESTO ES LO MÁS IMPORTANTE
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon, color: Colors.green[700]),
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
              // QUITAR isDense: true para que ocupe todo el ancho
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}