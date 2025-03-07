import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URLs base separadas
  static const String baseAuthUrl = 'https://airtecs-lgfl.onrender.com/autenticacionTecnicos';
  static const String baseSolicitudUrl = 'https://airtecs-lgfl.onrender.com/aceptacionSolicitud';
  static const String baseSoliIdUrl = 'https://airtecs-lgfl.onrender.com/solicitudes'; // Debe estar bien configurada
  static const String baseActualizacionUrl = 'https://airtecs-lgfl.onrender.com/actualizacion';
  static const String baseProgresoUrl = 'https://airtecs-lgfl.onrender.com/progresoT'; // 📌 Nueva Base URL
  static const String baseProfileUrl = 'https://airtecs-lgfl.onrender.com/tecnicos';
  static const String basePagoUrl = 'https://airtecs-lgfl.onrender.com/pago';

 

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

  // ✅ Función para actualizar el avatar del técnico
  static Future<Map<String, dynamic>?> updateTecnicoAvatar(String filePath) async {
    final token = await getToken();
    if (token == null) {
      print("🚨 No se puede actualizar el avatar: Token ausente.");
      return null;
    }

    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseAuthUrl/update-avatar'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('avatar', filePath));

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("✅ Avatar actualizado correctamente.");
        return jsonDecode(responseData);
      } else {
        print("❌ Error al actualizar avatar: ${response.statusCode}");
        print("📌 Respuesta: $responseData");
        return null;
      }
    } catch (e) {
      print("❌ Error en la solicitud de actualización de avatar: $e");
      return null;
    }
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

  // ✅ Obtener perfil del técnico autenticado
  static Future<Map<String, dynamic>?> getPerfilTecnico() async {
    final token = await getToken();

    if (token == null) {
      print("🚨 No se puede obtener el perfil: Token ausente.");
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseProfileUrl/perfil'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("⚠️ Error al obtener perfil: ${response.statusCode}");
      print("📌 Respuesta: ${response.body}");
      print("🔍 Token enviado: Bearer $token");
      return null;
      
    }
    
  }

 // ✅ Obtener detalles de un pago por ID de Solicitud
static Future<Map<String, dynamic>?> obtenerPagoPorSolicitud(String solicitudId) async {
  final url = Uri.parse('$basePagoUrl/solicitud/$solicitudId');

  try {
    final response = await http.get(url);

    print("📡 Solicitando pago para la solicitud ID: $solicitudId");
    print("📋 Respuesta completa: ${response.body}");

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);

      if (decodedData != null && decodedData is Map<String, dynamic> && decodedData.isNotEmpty) {
        print("✅ Pago encontrado: $decodedData");
        return decodedData;
      } else {
        print("⚠️ La respuesta está vacía o no es válida.");
        return null;
      }
    } else if (response.statusCode == 404) {
      print("⚠️ No se encontró un pago para esta solicitud.");
      return null;
    } else {
      print("❌ Error inesperado: ${response.statusCode} - ${response.reasonPhrase}");
      throw Exception("Error al obtener el pago: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error en la solicitud HTTP: $e");
    throw Exception("No se pudo obtener el pago");
  }
}

// ✅ Actualizar el estado de un pago
static Future<void> actualizarEstadoPago({
  required String pagoId,
  required String nuevoEstado,
}) async {
  final url = Uri.parse('$basePagoUrl/actualizar-estado/$pagoId');

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'estado': nuevoEstado}),
  );

  if (response.statusCode != 200) {
    throw Exception("❌ Error al actualizar el estado del pago: ${response.body}");
  } else {
    print("✅ Estado del pago actualizado a $nuevoEstado");
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

static Future<String?> obtenerNombreUsuario(String userId) async {
  final token = await getToken();

  if (token == null) {
    print("🚨 No se puede obtener el nombre del usuario: Token ausente.");
    return null;
  }

  final response = await http.get(
    Uri.parse('$baseSolicitudUrl/solicitudes-pendientes'), // 📌 Ajusta la URL según tu API
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    
    print("📌 Respuesta de la API para obtener usuario: $data"); // 🔥 Imprime la respuesta para depuración

    if (data is List && data.isNotEmpty) {
      // ✅ Si la API devuelve una lista, tomamos el primer elemento
      return data[0]['nombre'] as String?;
    } else if (data is Map) {
      // ✅ Si la API devuelve un objeto, accedemos directamente
      return data['nombre'] as String?;
    } else {
      print("⚠️ La API devolvió un formato inesperado: $data");
      return null;
    }
  } else {
    print("❌ Error al obtener el nombre del usuario: ${response.body}");
    return null;
  }
}

// ✅ Obtener detalles de una solicitud específica por ID
static Future<Map<String, dynamic>?> getSolicitudById(String solicitudId) async {
  final token = await getToken();

  if (token == null) {
    print("🚨 No se puede obtener la solicitud: Token ausente.");
    return null;
  }

  final response = await http.get(
    Uri.parse('$baseSoliIdUrl/solicitud/$solicitudId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print('Error: ${response.statusCode}');
  print('Contenido: ${response.body}'); // Verifica qué está devolviendo la API
  throw Exception('Error al obtener la solicitud.');
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

// ✅ Función para actualizar estado
  static Future<void> actualizarEstadoServicio({
    required String solicitudId,
    required String estado,
    String? codigoConfirmacion,  // 🔥 Asegurar que el parámetro está definido
    String? detalles,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token no encontrado. Inicia sesión de nuevo.');
    }

    final response = await http.post(
      Uri.parse('$baseProgresoUrl/actualizar-estado/$solicitudId'),
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



// ✅ Obtener el estado de la solicitud desde la API
static Future<String?> obtenerEstadoSolicitud(String solicitudId) async {
  final token = await getToken();

  if (token == null) {
    print("🚨 No se puede obtener el estado: Token ausente.");
    return null;
  }

  final response = await http.get(
    Uri.parse('$baseProgresoUrl/$solicitudId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    
    print("🔥 Estado recibido desde API: ${data["estado_solicitud"]}"); // 👀 Verificar qué devuelve la API

    return data["estado_solicitud"] ?? 'Pendiente';
  } else {
    print("❌ Error al obtener el estado: ${response.body}");
    return null;
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

