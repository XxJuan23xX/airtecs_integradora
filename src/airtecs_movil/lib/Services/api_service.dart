import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URLs base separadas
  static const String baseAuthUrl = 'http://localhost:3000/autenticacionTecnicos';
  static const String baseSolicitudUrl = 'http://localhost:3000/aceptacionSolicitud';

  // ✅ Registrar técnico
  static Future<Map<String, dynamic>> registerTecnico(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseAuthUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Error al registrar.',
      );
    }
  }

  // ✅ Iniciar sesión de técnico
  static Future<Map<String, dynamic>> loginTecnico(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseAuthUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // Guarda el `session_token` correctamente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_token', responseData['session_token']);

      return responseData;
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Error al iniciar sesión.',
      );
    }
  }

  // ✅ Obtener solicitudes pendientes
  static Future<List<dynamic>> getSolicitudesPendientes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('session_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token no encontrado. Inicia sesión de nuevo.');
    }

    final response = await http.get(
      Uri.parse('$baseSolicitudUrl/solicitudes-pendientes'), // ✅ Ruta correcta
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Error al obtener solicitudes pendientes.',
      );
    }
  }

  // ✅ Aceptar solicitud
  static Future<void> aceptarSolicitud(String solicitudId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('session_token');

    if (token == null || token.isEmpty) {
      throw Exception('Token no encontrado. Inicia sesión de nuevo.');
    }

    final response = await http.put(
      Uri.parse('$baseSolicitudUrl/aceptar-solicitud/$solicitudId'), // ✅ Ruta corregida
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Error al aceptar la solicitud.',
      );
    }
  }
}
