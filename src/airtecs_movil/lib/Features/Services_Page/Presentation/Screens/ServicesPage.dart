import 'package:flutter/material.dart';
import 'package:airtecs_movil/Services/api_service.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_bottom_bar.dart';
import 'package:airtecs_movil/Features/Services_Page/Presentation/Screens/ProfileScreen.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<dynamic> solicitudes = [];
  bool isLoading = false;
  double _progress = 0.0;
  String currentStatus = 'en camino'; // Estado inicial por defecto
  bool hasActiveService = false; // Para controlar si hay una solicitud en curso

  // ✅ Función para obtener la URL del avatar
String getAvatarUrl(String? avatar) {
  if (avatar != null && avatar.startsWith('http')) {
    return avatar; // URL completa
  } else if (avatar != null && avatar.isNotEmpty) {
    // Ruta relativa desde el backend
    return 'https://airtecs-lgfl.onrender.com/$avatar';
  } else {
    // Imagen por defecto
    return 'https://airtecs-lgfl.onrender.com/uploads/avatar-default.jpg';
  }
}


  @override
  void initState() {
    super.initState();
    _startFakeLoading(); // 🔥 Inicia la animación de la barra
    cargarSolicitudes();
  }

   // ✅ Simula el progreso de la barra de carga hasta llegar al 100%
  void _startFakeLoading() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _progress += 0.2; // 🔥 Incremento del progreso
          if (_progress < 1.0) _startFakeLoading(); // 🔄 Llamado recursivo hasta llegar al 100%
        });
      }
    });
  }

  bool isValidNextStatus(String currentStatus, String newStatus) {
    Map<String, String> validTransitions = {
      'pendiente': 'en camino',
      'en camino': 'en lugar',
      'en lugar': 'en proceso',
      'en proceso': 'finalizado',
      'finalizado': 'pagado',
    };

    currentStatus = currentStatus.trim().toLowerCase();
    newStatus = newStatus.trim().toLowerCase();

    print("📌 Validando transición de '$currentStatus' ➡️ '$newStatus'");

    return validTransitions[currentStatus] == newStatus;
  }

Future<void> cargarSolicitudes() async {
  setState(() {
    isLoading = true;
  });

  try {
    final data = await ApiService.getSolicitudesAceptadas();

    final solicitudesFiltradas = data.where((solicitud) {
      final estado = solicitud["estado"]?.toLowerCase().trim() ?? 'pendiente';
      // Mostrar todas las solicitudes excepto las "pagado"
      return estado != "pagado";
    }).toList();

    setState(() {
      solicitudes = solicitudesFiltradas;
      hasActiveService = solicitudesFiltradas.isNotEmpty;
    });

    print("📌 Cantidad de solicitudes activas encontradas: ${solicitudes.length}");

    // ✅ Mostrar el modal si hay alguna solicitud en "finalizado"
for (var solicitud in solicitudesFiltradas) {
  final solicitudId = solicitud['_id'];

  // ✅ Llamar a la API para obtener el estado real
  ApiService.obtenerEstadoSolicitud(solicitudId).then((estadoReal) {
    estadoReal = estadoReal?.toLowerCase().trim() ?? 'pendiente';
    print("📌 Estado real desde la API para $solicitudId: $estadoReal");

    // ✅ Mostrar el modal solo si el estado real es "finalizado"
    if (estadoReal == "finalizado") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPaymentConfirmationModal(solicitudId);
      });
    }
  }).catchError((error) {
    print("❌ Error obteniendo el estado de la API para $solicitudId: $error");
  });
}


  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${error.toString()}")),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}



  String getNextStatusFromList(String currentStatus) {
    List<String> estados = ['pendiente', 'en camino', 'en lugar', 'en proceso', 'finalizado', 'pagado'];

    currentStatus = currentStatus.trim().toLowerCase();

    int currentIndex = estados.indexOf(currentStatus);

    if (currentIndex >= 0 && currentIndex < estados.length - 1) {
      return estados[currentIndex + 1];
    }

    return estados.last;
  }

Future<String> getNextStatus(String solicitudId) async {
  final String? estadoActual = await ApiService.obtenerEstadoSolicitud(solicitudId);
  print("🔥 Estado recibido desde API: $estadoActual");

  // Si la API devuelve null, lo tratamos como "pendiente"
  String currentStatus = (estadoActual?.trim() ?? 'pendiente').toLowerCase();

  // No avanzar automáticamente si el estado es "finalizado"
  if (currentStatus == 'finalizado') {
    return 'finalizado';
  }

  List<String> estados = ['pendiente', 'en camino', 'en lugar', 'en proceso', 'finalizado', 'pagado'];

  int currentIndex = estados.indexOf(currentStatus);

  if (currentIndex >= 0 && currentIndex < estados.length - 1) {
    String nextStatus = estados[currentIndex + 1];
    print("🎯 Estado que se mostrará en el botón: $nextStatus");
    return nextStatus;
  }

  return estados.last;
}






  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'lib/assets/images/imagen.jpg',
            width: 40,
            height: 40,
          ),
        ),
      ],
    ),
    body: isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Cargando servicios...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 10,
                      backgroundColor: Colors.blue[100],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            )
        : hasActiveService
            ? ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: solicitudes.length,
  itemBuilder: (context, index) {
    final solicitud = solicitudes[index];

return FutureBuilder<String>(
  future: getNextStatus(solicitud['_id']),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    String estadoActual = snapshot.data!;
    print("🔄 Estado actual de la solicitud: $estadoActual");

    // ❌ Ocultar solicitudes solo si están en estado "pagado"
    if (estadoActual == "pagado") {
      return const SizedBox();
    }

    // ✅ Mostrar el modal de pago si la solicitud está finalizada
    // ✅ Solo retorna la tarjeta, no muestra el modal aquí
return _buildSolicitudCard(solicitud);
  },
);

                  },
                )
              : const Center(
                  child: Text(
                    "No tienes una solicitud en curso.",
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                ),
                bottomNavigationBar: WidgetBottomBar(
        selectedIndex: 1, // 🔥 Si estás en la página de perfil, pasa 2
        onHomePressed: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
        onServicesPressed: () {
          Navigator.pushNamed(context, '/services');
        },
        onProfilePressed: () {
          // ✅ Aquí agregamos la navegación a la pantalla de perfil
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
    );
  }


  Widget _buildSolicitudCard(Map<String, dynamic> solicitud) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Solicitud en curso",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Detalles del servicio",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 18),
          Text(
            "${solicitud['tipo_servicio'] ?? 'Cargando...'}",
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Text(
            "${solicitud['detalles'] ?? 'Cargando...'}",
            style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 80, 80, 80)),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on, "Dirección", solicitud['direccion'], Colors.red),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.calendar_today, "Fecha", solicitud['fecha'], Colors.blue),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.access_time, "Hora", solicitud['hora'], Colors.green),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.code, "Código", solicitud['codigo'], Colors.grey),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.build, "Marca", solicitud['marca_ac'], Colors.amber),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                "Solicitado por: ${solicitud['nombre_usuario'] ?? 'Cargando...'}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 20),
              Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color.fromARGB(255, 227, 51, 233), width: 2),
        image: DecorationImage(
          image: NetworkImage(
            getAvatarUrl(solicitud['avatar']), // ✅ Usando la función para obtener la URL correcta
          ),
          fit: BoxFit.cover,
        ),
      ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ElevatedButton(
              onPressed: () {
                showStatusUpdateBottomSheet(context, solicitud['_id']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Actualizar Estado",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start, // 🔥 Permite que el texto crezca hacia abajo
    children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(width: 10),
      Expanded( // 🔥 Evita desbordamiento y permite salto de línea
        child: Text(
          "$label: $value",
          style: const TextStyle(fontSize: 16),
          softWrap: true,  // ✅ Permite saltos de línea
          overflow: TextOverflow.visible, // ✅ Evita recorte del texto
        ),
      ),
    ],
  );
}

  void showStatusUpdateBottomSheet(BuildContext context, String solicitudId) {
    TextEditingController detallesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FutureBuilder<String>(
          future: getNextStatus(solicitudId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            String nextStatus = snapshot.data!;
            print("🎯 Estado actualizado que se mostrará en el botón: $nextStatus");

            return StatefulBuilder(
              builder: (context, setState) {
                return AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Actualizar Estado",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                nextStatus = getNextStatusFromList(nextStatus);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            ),
                            child: Text(
                              nextStatus,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: detallesController,
                            decoration: InputDecoration(
                              labelText: 'Mensaje a enviar',
                              labelStyle: const TextStyle(color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blue, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blue, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                print("🚀 Enviando actualización de estado a la API...");
                                String estadoActualAntes = (await ApiService.obtenerEstadoSolicitud(solicitudId) ?? 'pendiente')
                                    .trim()
                                    .toLowerCase();
                                print("🟢 Estado actual en la API antes de actualizar: $estadoActualAntes");

                                String estadoSiguiente = getNextStatusFromList(estadoActualAntes);
                                print("🔵 Estado que se enviará a la API: $estadoSiguiente");

                                if (estadoActualAntes == estadoSiguiente) {
                                  print("⚠️ El estado ya está actualizado, no es necesario enviarlo.");
                                  return;
                                }

                                await ApiService.actualizarEstadoServicio(
                                  solicitudId: solicitudId,
                                  estado: estadoSiguiente,
                                  detalles: detallesController.text.trim().isEmpty
                                      ? null
                                      : detallesController.text.trim(),
                                );

                                print("✅ Estado enviado con éxito: $estadoSiguiente");

                                await Future.delayed(const Duration(seconds: 2));

                                String estadoActualDespues = "";
                                int intentos = 0;
                                while (intentos < 3) {
                                  estadoActualDespues = (await ApiService.obtenerEstadoSolicitud(solicitudId) ?? 'pendiente')
                                      .trim()
                                      .toLowerCase();
                                  print("🔄 Intento ${intentos + 1}: Estado recibido después de actualizar: $estadoActualDespues");

                                  if (estadoActualDespues == estadoSiguiente) {
                                    break;
                                  }
                                  await Future.delayed(const Duration(seconds: 1));
                                  intentos++;
                                }

                                setState(() {
                                  currentStatus = estadoActualDespues;
                                });

                                cargarSolicitudes();

                                FocusScope.of(context).unfocus();
                                Navigator.pop(context);

                              } catch (error) {
                                print("❌ Error al actualizar estado: $error");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: ${error.toString()}")),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                            ),
                            child: const Text(
                              "Actualizar Estado",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
void _showPaymentConfirmationModal(String solicitudId) async {
  // 🔥 Obtener los datos del pago desde la API
  Map<String, dynamic>? pagoData;

  try {
    pagoData = await ApiService.obtenerPagoPorSolicitud(solicitudId);
  } catch (error) {
    print("❌ Error al obtener el pago: $error");
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.payment, color: Colors.blue, size: 28),
            SizedBox(width: 10),
            Text(
              "Confirmar Pago",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: pagoData != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    "Pago recibido:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "💵 Monto: \$${double.tryParse(pagoData['monto'].toString())?.toStringAsFixed(2) ?? '0.00'}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                  Text(
                    "💳 Método de Pago: ${pagoData['metodo_pago']}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.info_outline, color: Colors.orange, size: 50),
                  SizedBox(height: 10),
                  Text(
                    "Aún no hay pago del cliente.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text(
              "Cancelar",
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton.icon(
  onPressed: pagoData != null
      ? () async {
          try {
            // 🔥 1. Actualizar el estado en la colección solicitudes_servicio
            await ApiService.actualizarEstadoServicio(
              solicitudId: solicitudId,
              estado: "pagado",
              detalles: "Pago confirmado por el técnico",
            );

            // 🔥 2. Actualizar el estado en la colección pagos
            if (pagoData != null && pagoData['_id'] != null) {
  await ApiService.actualizarEstadoPago(
    pagoId: pagoData['_id'],
    nuevoEstado: "confirmado",
  );
} else {
  print("⚠️ Error: pagoData o el _id es nulo.");
}


            // ✅ Confirmación y cierre del modal
            Navigator.pop(context);
            cargarSolicitudes(); // Refresca la lista de solicitudes

            // ✅ Feedback visual
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✅ Pago confirmado exitosamente."),
                backgroundColor: Colors.green,
              ),
            );
          } catch (error) {
            print("❌ Error al confirmar el pago: $error");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ Error al confirmar el pago: $error"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      : null, // Deshabilita el botón si no hay pago
  icon: const Icon(Icons.check),
  label: const Text("Confirmar Pago"),
  style: ElevatedButton.styleFrom(
    backgroundColor: pagoData != null ? Colors.blue : Colors.grey,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
),

        ],
      );
    },
  );
}


}