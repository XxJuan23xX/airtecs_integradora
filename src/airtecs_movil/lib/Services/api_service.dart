import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ✅ Definir las bases de URL generales
  static const String baseAuthUrl = 'http://localhost:3000/autenticacionTecnicos';
  static const String baseSolicitudUrl = 'http://localhost:3000/aceptacionSolicitud';
  static const String baseActualizacionUrl = 'http://localhost:3000/actualizacion';
  static const String baseProgresoUrl = 'http://localhost:3000/progresoT'; // 🔥 No se toca
  static const String baseSolicitudesUrl = 'http://localhost:3000/solicitudes-tecnicos';
  static const String baseProgresoServicioUrl = 'http://localhost:3000/progreso'; // ✅ Nueva Base URL

  // ✅ Función para obtener el token almacenado en SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('session_token');

    if (token == null || token.isEmpty) {
      print("❌ Token no encontrado en SharedPreferences.");
      return null;
    }

    print("📌 Token obtenido de SharedPreferences: $token");
    return token;
  }

  // ✅ Guardar token después del login
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_token', token);
    print("✅ Token guardado correctamente en SharedPreferences.");
  }

  // ✅ Eliminar token al cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token');
    print("🚀 Token eliminado al cerrar sesión.");
  }

  // ✅ Registrar técnico (NO SE TOCA)
  static Future<Map<String, dynamic>> registerTecnico(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseAuthUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Error al registrar técnico.');
    }
  }

  // ✅ Iniciar sesión de técnico (NO SE TOCA)
  static Future<Map<String, dynamic>> loginTecnico(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseAuthUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      await saveToken(responseData['session_token']);
      return responseData;
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Error al iniciar sesión.');
    }
  }

  // ✅ Obtener solicitudes pendientes para técnicos con detalles (NO SE TOCA)
  static Future<List<dynamic>> getSolicitudesPendientesDetalles() async {
    final token = await getToken();

    if (token == null) {
      print("🚨 No se puede obtener solicitudes pendientes: Token ausente.");
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseSolicitudesUrl/pendientes-tecnicos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Error al obtener solicitudes pendientes.');
    }
  }

  // ✅ Aceptar solicitud (NO SE TOCA)
  static Future<void> aceptarSolicitud(String solicitudId) async {
    final token = await getToken();

    if (token == null) {
      print("🚨 No se puede aceptar la solicitud: Token ausente.");
      throw Exception('Token no encontrado. Inicia sesión de nuevo.');
    }

    final response = await http.put(
      Uri.parse('$baseSolicitudUrl/aceptar-solicitud/$solicitudId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Error al aceptar la solicitud.');
    }
  }

  // ✅ Obtener solicitudes aceptadas (NO SE TOCA)
  static Future<List<dynamic>> getSolicitudesAceptadas() async {
    final token = await getToken();

    if (token == null) {
      print("🚨 No se puede obtener solicitudes aceptadas: Token ausente.");
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseSolicitudUrl/solicitudes-aceptadas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Error al obtener solicitudes aceptadas.');
    }
  }
///obtener el estado actual de una solicitud en `progreso`//
static Future<List<dynamic>> getHistorialEstados(String solicitudId) async {
  final token = await getToken();

  if (token == null) {
    print("🚨 No se puede obtener el historial: Token ausente.");
    return [];
  }

  try {
    final response = await http.get(
      Uri.parse('$baseProgresoServicioUrl/$solicitudId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data is List) ? data : [];
    } else {
      return [];
    }
  } catch (error) {
    print("❌ Excepción en getHistorialEstados: $error");
    return [];
  }
}



  // ✅ Actualizar estado del servicio (NO SE TOCA)
  static Future<void> actualizarEstadoServicio({
    required String solicitudId,
    required String estado,
    String? codigoConfirmacion,
    String? detalles,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token no encontrado. Inicia sesión de nuevo.');
    }

    final response = await http.post(
      Uri.parse('$baseActualizacionUrl/actualizar-estado/$solicitudId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "estado": estado,
        if (codigoConfirmacion != null) "codigoConfirmacion": codigoConfirmacion,
        if (detalles != null) "detalles": detalles,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Error al actualizar el estado del servicio.',
      );
    }
  }

  // ✅ Obtener servicios finalizados (NO SE TOCA)
  static Future<List<dynamic>> getServiciosFinalizados() async {
    final token = await getToken();

    if (token == null) {
      print("🚨 No se puede obtener servicios finalizados: Token ausente.");
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseProgresoUrl/solicitudes-finalizadas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Error al obtener servicios finalizados.');
    }
  }
}
