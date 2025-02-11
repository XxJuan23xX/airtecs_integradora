import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:airtecs_movil/Services/api_service.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_bottom_bar.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_navbar.dart';
import 'package:airtecs_movil/Features/Services_Page/Presentation/Screens/ServiceDetailScreen.dart';
import 'package:airtecs_movil/Features/Session/Presentation/Screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> solicitudes = [];
  List<dynamic> solicitudesFiltradas = [];
  bool isLoading = false;
  String? categoriaSeleccionada;

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
      setState(() {
        solicitudes = data;
        solicitudesFiltradas = List.from(solicitudes);
      });
    } catch (error) {
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

  void filtrarServiciosPorCategoria(String categoria) {
    setState(() {
      categoriaSeleccionada = categoria;

      if (categoria == "Aires Acondicionados") {
        solicitudesFiltradas = solicitudes.where((solicitud) {
          final serviceName = solicitud['tipo_servicio'] ?? '';
          return serviceName.toLowerCase().contains('aires acondicionados');
        }).toList();
      } else if (categoria == "Refrigeradores") {
        solicitudesFiltradas = solicitudes.where((solicitud) {
          final serviceName = solicitud['tipo_servicio'] ?? '';
          return serviceName.toLowerCase().contains('refrigeradores');
        }).toList();
      }
    });
  }

  void mostrarTodosLosServicios() {
    setState(() {
      categoriaSeleccionada = null;
      solicitudesFiltradas = List.from(solicitudes);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: WidgetNavbar(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                "Categorías",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryItem('Aires Acondicionados', 'lib/assets/images/airecategory.jpg'),
                _buildCategoryItem('Refrigeradores', 'lib/assets/images/refricategory.webp'),
              ],
            ),
            if (categoriaSeleccionada != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextButton(
                  onPressed: mostrarTodosLosServicios,
                  child: const Text("Mostrar Todos", style: TextStyle(color: Colors.blue)),
                ),
              ),
            const Divider(thickness: 1.2),
            const SizedBox(height: 5),
            const Text(
              "Algunos Servicios Solicitados",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: solicitudesFiltradas.isEmpty && !isLoading
                  ? const Center(
                      child: Text(
                        "No hay servicios disponibles en esta categoría.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: solicitudesFiltradas.length,
                          itemBuilder: (context, index) {
                            final solicitud = solicitudesFiltradas[index];
                            final String serviceName = solicitud['tipo_servicio'] ?? 'Servicio desconocido';
                            final String serviceImage = getServiceImage(serviceName);
                            final String descripcion = solicitud['detalles'] ?? 'Sin descripción';
                            final String direccion = solicitud['direccion'] ?? 'Ubicación desconocida';

                            return _buildServiceCard(
                              context,
                              serviceName,
                              serviceImage,
                              descripcion,
                              direccion,
                              solicitud['fecha'],
                              solicitud['_id'],
                              solicitud['hora'],
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

  Widget _buildCategoryItem(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        filtrarServiciosPorCategoria(title);
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}


  Widget _buildServiceCard(
    BuildContext context,
    String name,
    String image,
    String details,
    String address,
    String date,
    String solicitudId,
    String hora,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      color: const Color.fromARGB(255, 248, 248, 248),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Color.fromARGB(255, 186, 25, 25)),
                      const SizedBox(width: 5),
                      Text(date, style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 98, 98, 98))),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color.fromARGB(255, 43, 151, 13)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 98, 98, 98)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceDetailScreen(
                      serviceName: name,
                      serviceImage: image,
                      descripcion: details,
                      direccion: address,
                      solicitudId: solicitudId,
                      fecha: date,
                      hora: hora,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              ),
              child: const Text("Detalles", style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

