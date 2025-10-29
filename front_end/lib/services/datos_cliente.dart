
import 'dart:convert';
import 'package:http/http.dart' as http;

class DatosClienteService {
  static const String baseUrl = 'http://localhost:3000/api/datos-cliente';

 
  static Future<Map<String, dynamic>> obtenerUsuario(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener usuario: $error');
    }
  }


  static Future<Map<String, dynamic>> actualizarUsuario(String id, Map<String, dynamic> datosUsuario) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datosUsuario),
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al actualizar usuario: $error');
    }
  }

  static Future<Map<String, dynamic>> obtenerUsuariosPorRol(String rol) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rol/$rol'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener usuarios por rol: $error');
    }
  }
}