import 'dart:convert';
import 'package:http/http.dart' as http;

class ProxyService {
  static const String baseUrl = 'http://localhost:3000/api/proxy';

  /// Obtiene la foto de portada (baja resolución) para cards
  static Future<String> getFotoPortada(String habitacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foto-portada/$habitacionId'),
      );

      if (response.statusCode == 200) {
        // Convertir la imagen a base64 para mostrarla
        final base64Image = base64Encode(response.bodyBytes);
        // convierte los bytes de la imagen del proxy
        return 'data:image/jpeg;base64,$base64Image';
      } else {
        throw Exception('Error al obtener foto de portada: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error en ProxyService.getFotoPortada: $error');
    }
  }

  /// Verifica si una habitación tiene foto de portada
  static Future<bool> hasFotoPortada(String habitacionId) async {
    try {
      final response = await http.head(
        Uri.parse('$baseUrl/foto-portada/$habitacionId'),
        //usa metodo head para verificar existencia sin descargar la imagen completa
      );
      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
  }
}