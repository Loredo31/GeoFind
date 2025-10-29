
import 'dart:convert';
import 'package:http/http.dart' as http;

class ResenaService {
  static const String baseUrl = 'http://localhost:3000/api/resena';

 
  static Future<Map<String, dynamic>> crearResena(Map<String, dynamic> datosResena) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datosResena),
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al crear reseña: $error');
    }
  }

  static Future<Map<String, dynamic>> obtenerResenasHabitacion(String habitacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/habitacion/$habitacionId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener reseñas de la habitación: $error');
    }
  }

  static Future<Map<String, dynamic>> obtenerTodasLasResenas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener todas las reseñas: $error');
    }
  }
}