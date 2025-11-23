// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ResenaService {
//   static const String baseUrl = 'http://localhost:3000/api/resena'; 

//   // Crear reseña
//   static Future<Map<String, dynamic>> crearResena(Map<String, dynamic> datosResena) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(datosResena),
//       );

//       final data = json.decode(response.body);
//       return data;
//     } catch (error) {
//       throw Exception('Error al crear reseña: $error');
//     }
//   }

//   // Obtener reseñas por habitación
//   static Future<Map<String, dynamic>> obtenerResenasHabitacion(String habitacionId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/habitacion/$habitacionId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       final data = json.decode(response.body);
//       return data;
//     } catch (error) {
//       throw Exception('Error al obtener reseñas de la habitación: $error');
//     }
//   }

//   // Obtener todas las reseñas
//   static Future<Map<String, dynamic>> obtenerTodasLasResenas() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       final data = json.decode(response.body);
//       return data;
//     } catch (error) {
//       throw Exception('Error al obtener todas las reseñas: $error');
//     }
//   }

//   // Obtener datos para gráfica de dispersión
//   static Future<Map<String, dynamic>> obtenerDatosGraficaDispersion(String habitacionId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/grafica-dispersion/$habitacionId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       final data = json.decode(response.body);
//       return data;
//     } catch (error) {
//       throw Exception('Error al obtener datos para gráfica de dispersión: $error');
//     }
//   }

//   // Obtener promedios de calificaciones
//   static Future<Map<String, dynamic>> obtenerPromedioCalificaciones(String habitacionId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/promedios/$habitacionId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       final data = json.decode(response.body);
//       return data;
//     } catch (error) {
//       throw Exception('Error al obtener promedios de calificaciones: $error');
//     }
//   }

//   // Obtener evolución de calificaciones
//   static Future<Map<String, dynamic>> obtenerEvolucionCalificaciones(String habitacionId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/evolucion/$habitacionId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       final data = json.decode(response.body);
//       return data;
//     } catch (error) {
//       throw Exception('Error al obtener evolución de calificaciones: $error');
//     }
//   }

//   static Future<Map<String, dynamic>> obtenerDatosGraficaBarras(String habitacionId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/grafica-barras/$habitacionId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       final data = json.decode(response.body);
//       return data;
//     } catch (error) {
//       throw Exception('Error al obtener datos para gráfica de barras: $error');
//     }
//   }

//   // Obtener datos para gráfica de área
//   static Future<Map<String, dynamic>> obtenerDatosGraficaArea(String habitacionId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/grafica-area/$habitacionId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       final data = json.decode(response.body);
//       return data;
//     } catch (error) {
//       throw Exception('Error al obtener datos para gráfica de área: $error');
//     }
//   }

//   // Obtener datos para gráfica de radar
//   static Future<Map<String, dynamic>> obtenerDatosGraficaRadar(String habitacionId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/grafica-radar/$habitacionId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       final data = json.decode(response.body);
//       return data;
//     } catch (error) {
//       throw Exception('Error al obtener datos para gráfica de radar: $error');
//     }
//   }
// }



import 'dart:convert';
import 'package:http/http.dart' as http;

class ResenaService {
  static const String baseUrl = 'http://localhost:3000/api/resena'; // ✅ Cambiado a plural

  // Crear reseña
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

  // Obtener reseñas por habitación
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

  // Obtener todas las reseñas
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

  // Obtener datos para gráfica de dispersión
  static Future<Map<String, dynamic>> obtenerDatosGraficaDispersion(String habitacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grafica-barras-doble/$habitacionId'), // ✅ Ruta corregida
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener datos para gráfica de dispersión: $error');
    }
  }

  // Obtener promedios de calificaciones
  static Future<Map<String, dynamic>> obtenerPromedioCalificaciones(String habitacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/promedios/$habitacionId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener promedios de calificaciones: $error');
    }
  }

  // Obtener evolución de calificaciones
  static Future<Map<String, dynamic>> obtenerEvolucionCalificaciones(String habitacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/evolucion/$habitacionId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener evolución de calificaciones: $error');
    }
  }

  // Obtener datos para gráfica de barras
  static Future<Map<String, dynamic>> obtenerDatosGraficaBarras(String habitacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grafica-barras/$habitacionId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener datos para gráfica de barras: $error');
    }
  }

  // Obtener datos para gráfica de área
  static Future<Map<String, dynamic>> obtenerDatosGraficaArea(String habitacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grafica-area/$habitacionId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener datos para gráfica de área: $error');
    }
  }

  // Obtener datos para gráfica de radar
  static Future<Map<String, dynamic>> obtenerDatosGraficaRadar(String habitacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grafica-radar/$habitacionId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener datos para gráfica de radar: $error');
    }
  }

  // ✅ NUEVO: Obtener datos para gráfica de barras dobles
  static Future<Map<String, dynamic>> obtenerDatosGraficaBarrasDobles(String habitacionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grafica-barras-doble/$habitacionId'), // ✅ Ruta corregida
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data;
    } catch (error) {
      throw Exception('Error al obtener datos para gráfica de barras dobles: $error');
    }
  }

  // ✅ MÉTODO AUXILIAR: Extraer datos de la respuesta
  static dynamic extraerDatos(Map<String, dynamic> response) {
    return response['success'] ? response['data'] : null;
  }
}