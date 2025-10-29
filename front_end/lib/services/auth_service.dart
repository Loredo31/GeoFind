import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api/auth';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error de conexión: $error');
    }
  }

  static Future<Map<String, dynamic>> register(
    String nombre,
    String email,
    String password,
    String rol,
    String telefono,
    String direccion,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'email': email,
          'password': password,
          'rol': rol,
          'telefono': telefono,
          'direccion': direccion,
        }),
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error de conexión: $error');
    }
  }
}