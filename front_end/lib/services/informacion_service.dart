// services/informacion_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class InformacionService {
  static const String baseUrl = 'http://localhost:3000/api/informacion';

  // Crear información - POST /api/informacion
  static Future<Map<String, dynamic>> crearInformacion(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datos),
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al crear información: $error');
    }
  }

  // Obtener información por arrendador - GET /api/informacion/arrendador/:arrendadorId
  static Future<Map<String, dynamic>> obtenerInformacionArrendador(String arrendadorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arrendador/$arrendadorId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener información del arrendador: $error');
    }
  }

  // Obtener todas las habitaciones - GET /api/informacion
  static Future<Map<String, dynamic>> obtenerTodasLasHabitaciones() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener todas las habitaciones: $error');
    }
  }

  // Actualizar información - PUT /api/informacion/:id
  static Future<Map<String, dynamic>> actualizarInformacion(String id, Map<String, dynamic> datos) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datos),
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al actualizar información: $error');
    }
  }

  // Eliminar información - DELETE /api/informacion/:id
  static Future<Map<String, dynamic>> eliminarInformacion(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al eliminar información: $error');
    }
  }
}