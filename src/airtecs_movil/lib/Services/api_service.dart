import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URLs base separadas
  static const String baseAuthUrl = 'https://backend-ronp.onrender.com/autenticacionTecnicos';
  static const String baseSolicitudUrl = 'https://backend-ronp.onrender.com/aceptacionSolicitud';
  static const String baseActualizacionUrl = 'https://backend-ronp.onrender.com/actualizacion';
  static const String baseProgresoUrl = 'https://backend-ronp.onrender.com/progresoT'; // 📌 Nueva Base URL


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
      throw Exception(jsonDecode(response.body)['error'] ?? 'Error al registrar.');
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

      // Guarda el token correctamente
      await saveToken(responseData['session_token']);

      return responseData;
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Error al iniciar sesión.');
    }
  }

  // ✅ Obtener solicitudes pendientes
  static Future<List<dynamic>> getSolicitudesPendientes() async {
    final token = await getToken();

    if (token == null) {
      print("🚨 No se puede obtener solicitudes pendientes: Token ausente.");
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseSolicitudUrl/solicitudes-pendientes'),
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

  // ✅ Aceptar solicitud
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

  // ✅ Obtener solicitudes aceptadas
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

  // ✅ Actualizar estado del servicio
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
        if (codigoConfirmacion != null) "codigoConfirmacion": codigoConfirmacion, // 🔥 Debe enviarse aquí
        if (detalles != null) "detalles": detalles,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Error al actualizar el estado del servicio.',
      );
    }
  }

 // ✅ **Nuevo Método: Obtener Progreso de Servicio por ID**
  static Future<Map<String, dynamic>?> getProgresoPorSolicitud(String solicitudId) async {
    final token = await getToken();

    if (token == null) {
      print("🚨 No se puede obtener el progreso: Token ausente.");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseProgresoUrl/$solicitudId'), // 📌 Endpoint correcto
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 🔥 Filtrar solo los servicios con estado "finalizado"
      if (data["detallesServicio"] != null && data["detallesServicio"]["estado_solicitud"] == "finalizado") {
        return data;
      } else {
        print("⚠️ No se encontraron servicios finalizados para la solicitud ID: $solicitudId");
        return null;
      }
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Error al obtener el progreso del servicio.');
    }
  }

  // ✅ **Método para obtener Servicios Finalizados**
  static Future<List<dynamic>> getServiciosFinalizados() async {
    final token = await getToken();

    if (token == null) {
      print("🚨 No se puede obtener servicios finalizados: Token ausente.");
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseProgresoUrl/solicitudes-finalizadas'), // 📌 Endpoint correcto
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