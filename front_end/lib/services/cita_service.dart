// services/cita_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CitaService {
  static const String baseUrl = 'http://localhost:3000/api/agendar-cita';

  // Crear cita - POST /api/agendar-cita
  static Future<Map<String, dynamic>> crearCita(Map<String, dynamic> datosCita) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datosCita),
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al crear cita: $error');
    }
  }

  // Obtener citas por arrendador - GET /api/agendar-cita/arrendador/:habitacionId
  static Future<Map<String, dynamic>> obtenerCitasArrendador(String habitacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arrendador/$habitacionId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener citas del arrendador: $error');
    }
  }

  // Obtener citas por arrendatario - GET /api/agendar-cita/arrendatario/:arrendatarioId
  static Future<Map<String, dynamic>> obtenerCitasArrendatario(String arrendatarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arrendatario/$arrendatarioId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener citas del arrendatario: $error');
    }
  }

  // Actualizar estado de cita - PUT /api/agendar-cita/:id/estado
//   static Future<Map<String, dynamic>> actualizarEstadoCita(String citaId, String estado) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/$citaId/estado'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'estado': estado}),
//       );

//       final data = json.decode(response.body);
//       return data;
//     } catch (error) {
//       throw Exception('Error al actualizar estado de cita: $error');
//     }
//   }
// }



static Future<Map<String, dynamic>> actualizarEstadoCita(String citaId, bool estado) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/$citaId/estado'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'estado': estado}), // Aquí se envía el bool correctamente
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {
        'success': false,
        'message': 'Error al actualizar cita: ${response.statusCode}'
      };
    }
  } catch (error) {
    return {
      'success': false,
      'message': 'Error de conexión: $error'
    };
  }
}
}