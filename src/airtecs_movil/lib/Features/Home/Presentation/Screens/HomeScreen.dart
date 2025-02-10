import 'package:flutter/material.dart';
import 'package:airtecs_movil/Services/api_service.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_bottom_bar.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_navbar.dart';
import 'package:airtecs_movil/Features/Services_Page/Presentation/Screens/ServicesPage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<dynamic> solicitudes = [];
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Cargar solicitudes al iniciar
    cargarSolicitudes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> cargarSolicitudes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await ApiService.getSolicitudesPendientesDetalles();
      setState(() {
        solicitudes = data;
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

  Future<void> aceptarSolicitud(String solicitudId) async {
    print("🔎 ID de la solicitud a aceptar: $solicitudId");
    try {
      await ApiService.aceptarSolicitud(solicitudId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud aceptada con éxito.')),
        );
        // ✅ Redirigir a ServicesPage
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const ServicesPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al aceptar: ${error.toString()}')),
        );
      }
    }
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
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text("Solicitud #${solicitud['_id']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Dirección: ${solicitud['direccion']}"),
                            Text("Detalles: ${solicitud['detalles']}"),
                            Text("Marca AC: ${solicitud['marca_ac']}"),
                            Text("Tipo AC: ${solicitud['tipo_ac']}"),
                            Text("Fecha: ${solicitud['fecha']}"),
                            Text("Hora: ${solicitud['hora']}"),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => aceptarSolicitud(solicitud['_id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Aceptar"),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _scaleAnimation,
        child: FloatingActionButton(
          onPressed: cargarSolicitudes,
          backgroundColor: Colors.blue,
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.search),
        ),
      ),
      bottomNavigationBar: WidgetBottomBar(
        onHomePressed: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(-1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        },
        onServicesPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const ServicesPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
