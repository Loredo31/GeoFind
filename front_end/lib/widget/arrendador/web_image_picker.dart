import 'dart:async';
//import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';

class WebImagePicker extends StatelessWidget {
  final ValueChanged<List<String>> onImagesSelected;
  final VoidCallback onPickImages;

  const WebImagePicker({
    Key? key,
    required this.onImagesSelected,
    required this.onPickImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPickImages,
      icon: const Icon(Icons.add_photo_alternate),
      label: const Text('Seleccionar Fotos'),
    );
  }
}

// Función global para manejar la selección de archivos
Future<List<String>> pickImagesWeb() async {
  final completer = Completer<List<String>>();
  
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = true
    ..style.display = 'none';

  input.onChange.listen((e) async {
    final files = input.files;
    if (files != null && files.isNotEmpty) {
      final base64Images = <String>[];
      
      for (final file in files) {
        final reader = html.FileReader();
        final fileCompleter = Completer<void>();
        
        reader.onLoadEnd.listen((e) {
          if (reader.result != null) {
            // Convertir a base64 (remover el prefijo data:image/...;base64,)
            final String base64 = reader.result as String;
            final String pureBase64 = base64.split(',').last;
            base64Images.add(pureBase64);
          }
          fileCompleter.complete();
        });
        
        reader.readAsDataUrl(file);
        await fileCompleter.future;
      }
      
      completer.complete(base64Images);
    } else {
      completer.complete([]);
    }
    
    // Limpiar el input
    input.remove();
  });

  html.document.body!.append(input);
  input.click();

  return completer.future;
}