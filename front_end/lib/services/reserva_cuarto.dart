// services/reservar_cuarto_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReservarCuartoService {
  static const String baseUrl = 'http://localhost:3000/api/reservar-cuarto';

  // Crear reserva - POST /api/reservar-cuarto
  static Future<Map<String, dynamic>> crearReserva(Map<String, dynamic> datosReserva) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datosReserva),
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al crear reserva: $error');
    }
  }

  // Obtener reservas por arrendador - GET /api/reservar-cuarto/arrendador/:habitacionId
  static Future<Map<String, dynamic>> obtenerReservasArrendador(String habitacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arrendador/$habitacionId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener reservas del arrendador: $error');
    }
  }

  // Obtener reservas por arrendatario - GET /api/reservar-cuarto/arrendatario/:arrendatarioId
  static Future<Map<String, dynamic>> obtenerReservasArrendatario(String arrendatarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arrendatario/$arrendatarioId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener reservas del arrendatario: $error');
    }
  }

  // Actualizar estado de reserva - PUT /api/reservar-cuarto/:id/estado
  static Future<Map<String, dynamic>> actualizarEstadoReserva(String reservaId, String estado) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$reservaId/estado'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'estado': estado}),
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al actualizar estado de reserva: $error');
    }
  }
}