import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:airtecs_movil/Services/api_service.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_bottom_bar.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_navbar.dart';
import 'package:airtecs_movil/Features/Services_Page/Presentation/Screens/ServiceDetailScreen.dart';
import 'package:airtecs_movil/Features/Session/Presentation/Screens/login_screen.dart';
import 'package:airtecs_movil/Features/Services_Page/Presentation/Screens/ProfileScreen.dart'; // Asegúrate de importar la pantalla de perfil
import 'package:flutter/rendering.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> solicitudes = [];
  List<dynamic> solicitudesFiltradas = [];
  bool isLoading = false;
  int categoriaSeleccionada = 0; // 🔥 Índice de la categoría seleccionada
  double _progress = 0.0;
// 🔥 Controladores para manejar el scroll
final ScrollController _scrollController = ScrollController();
final ScrollController _categoryScrollController = ScrollController();

  final List<String> categorias = [
    "Todos",
    "Aires Acondicionados",
    "Refrigeradores",
  ];

  @override
  void initState() {
    super.initState();
    cargarSolicitudes();
    _startFakeLoading(); // 🔥 Inicia la animación de la barra
    _scrollController.addListener(_onScroll);
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

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
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

  // ✅ Filtrar Servicios por Categoría
void filtrarServicios(int index) {
    setState(() {
      categoriaSeleccionada = index;

      if (index == 0) {
        solicitudesFiltradas = List.from(solicitudes);
      } else {
        String categoriaTexto = categorias[index].toLowerCase();
        solicitudesFiltradas = solicitudes
            .where((solicitud) => solicitud['tipo_servicio'].toLowerCase().contains(categoriaTexto))
            .toList();
      }

      _moverBarraCategorias(index);
    });
  }
  void _moverBarraCategorias(int index) {
    double offset = index * 80.0;
    _categoryScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
// ✅ Mover la barra de categorías automáticamente
void _scrollToCategory(int index) {
  double offset = (index * 100).toDouble(); // 🔹 Ajusta el valor según el ancho de cada categoría
  _categoryScrollController.animateTo(
    offset,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
}

void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse ||
        _scrollController.position.userScrollDirection == ScrollDirection.forward) {
      double scrollOffset = _scrollController.offset;
      int nuevaCategoria = (scrollOffset / 300).floor().clamp(0, categorias.length - 1);

      if (nuevaCategoria != categoriaSeleccionada) {
        setState(() {
          categoriaSeleccionada = nuevaCategoria;
        });

        _moverBarraCategorias(nuevaCategoria);
      }
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

          // 🔥 Nueva Barra de Categorías con Scroll Automático
          SizedBox(
            height: 40,
            child: ListView.builder(
              controller: _categoryScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => filtrarServicios(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          categorias[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: categoriaSeleccionada == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: categoriaSeleccionada == index
                                ? Colors.blue
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (categoriaSeleccionada == index)
                          Container(
                            height: 3,
                            width: 30,
                            color: Colors.blue,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(thickness: 1.2),
          const SizedBox(height: 5),

          const Text(
            "Algunos Servicios Solicitados",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),

          // 🔥 SCROLL DETECTION PARA CAMBIAR CATEGORÍA
          // 🔥 Lista de Servicios con Scroll Detection
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollUpdateNotification) {
                    _onScroll();
                  }
                  return true;
                },
                child: isLoading
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
                        : ListView.builder(
                            controller: _scrollController,
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
                              solicitud['userId'],
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: WidgetBottomBar(
      selectedIndex: 0,
      onHomePressed: () {
        Navigator.pushReplacementNamed(context, '/home');
      },
      onServicesPressed: () {
        Navigator.pushNamed(context, '/services');
      },
      onProfilePressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      },
    ),
  );
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
  String userId, // ✅ Agregamos el userId como parámetro
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
                    Expanded(
                      child: Text(
                        date,
                        style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 98, 98, 98)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
  onPressed: () async {
    // ✅ Obtener el nombre del usuario desde la API, pero esta vez pasamos el solicitudId
    final solicitudDetalles = await ApiService.getSolicitudById(solicitudId);  // Usar solicitudId aquí

    if (!context.mounted) return; // ✅ Evitar problemas con context async

    final nombreUsuario = solicitudDetalles != null 
      ? solicitudDetalles['nombre_usuario'] ?? "Usuario desconocido" 
      : "Usuario desconocido"; // Obtener nombre de la respuesta

      // Obtener el avatar del usuario
// Obtener el avatar del usuario
final respuesta = await ApiService.getSolicitudById(solicitudId);
// Imprimir la respuesta completa en consola
print("🔍 Respuesta completa de la API: $respuesta");



final avatar = respuesta != null && respuesta.containsKey('avatar') && respuesta['avatar'] != null
    ? respuesta['avatar']
    : null;

// Imprime el avatar recibido
print("📸 Avatar recibido: $avatar");

// Construcción segura de la URL del avatar
final avatarUrl = (avatar != null && avatar.isNotEmpty)
    ? (avatar.startsWith('http')
        ? avatar // Si ya es una URL completa
        : 'https://airtecs-lgfl.onrender.com/$avatar') // Ruta relativa desde el backend
    : 'https://airtecs-lgfl.onrender.com/uploads/avatar-default.jpg'; // Imagen por defecto

print("🖼️ URL final del avatar: $avatarUrl");


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
          userId: userId, // ✅ Pasamos el userId
          nombreUsuario: nombreUsuario, // ✅ Pasamos el nombre obtenido
          avatar: avatarUrl, // ✅ Pasamos el avatarUrl corregido
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

}
