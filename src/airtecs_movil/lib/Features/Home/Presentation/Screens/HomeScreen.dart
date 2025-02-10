import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:airtecs_movil/Services/api_service.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_bottom_bar.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_navbar.dart';
import 'package:airtecs_movil/Features/Services_Page/Presentation/Screens/ServicesPage.dart';
import 'package:airtecs_movil/Features/Session/Presentation/Screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> solicitudes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    cargarSolicitudes();
  }

  Future<void> cargarSolicitudes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await ApiService.getSolicitudesPendientes();
      print("🔍 Datos recibidos desde API: $data"); // 🔹 Verifica los datos en consola

      setState(() {
        solicitudes = data;
      });
    } catch (error) {
      print("❌ Error al obtener solicitudes: $error");
      if (error.toString().contains('Token no encontrado')) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String getServiceImage(String serviceName) {
    final Map<String, String> serviceImages = {
      "Mantenimiento de aires acondicionados": "lib/assets/images/air_maintenance.jpg",
      "Reparación de aires acondicionados": "lib/assets/images/air_repair.png",
      "Limpieza de refrigeradores": "lib/assets/images/fridge_cleaning.jpg",
      "Reparación de refrigeradores": "lib/assets/images/fridge_repair.jpg",
    };
    return serviceImages[serviceName] ?? "lib/assets/images/AirTecs.png";
  }

  Future<void> aceptarSolicitud(String solicitudId) async {
    try {
      await ApiService.aceptarSolicitud(solicitudId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud aceptada con éxito.')),
        );
        Navigator.pushReplacementNamed(context, '/services');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al aceptar: ${error.toString()}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: const WidgetNavbar(title: "AIR TECS"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Servicios Pendientes.",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Selecciona alguno de los servicios disponibles",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (solicitudes.isEmpty && !isLoading)
              const Center(
                child: Text(
                  "No hay solicitudes pendientes.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: solicitudes.length,
                  itemBuilder: (context, index) {
                    final solicitud = solicitudes[index];
                    final String serviceName = solicitud['tipo_servicio'] ?? 'Servicio desconocido';
                    final String serviceImage = getServiceImage(serviceName);
                    final String descripcion = solicitud['detalles'] ?? 'Sin descripción';
                    final String direccion = solicitud['direccion'] ?? 'Ubicación desconocida';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // 🔹 Imagen dentro de un `Container` con fondo blanco y sombra
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  serviceImage,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error, color: Colors.red);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    serviceName,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    descripcion,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.grey, size: 16),
                                      Expanded(
                                        child: Text(
                                          direccion,
                                          style: const TextStyle(color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () => aceptarSolicitud(solicitud['_id']),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                  child: const Text("Aceptar"),
                                ),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text("Cancelar"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: WidgetBottomBar(
        onHomePressed: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
        onServicesPressed: () {
          Navigator.pushNamed(context, '/services');
        },
      ),
    );
  }
}
