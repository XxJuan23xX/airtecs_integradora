import 'package:flutter/material.dart';
import 'package:airtecs_movil/Services/api_service.dart';
import 'package:airtecs_movil/features/Services_Page/Presentation/Screens/ServicesPage.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceName;
  final String serviceImage;
  final String descripcion;
  final String direccion;
  final String solicitudId;
  final String fecha;
  final String hora;
  final String userId; // Se recibe el ID del usuario
  final String nombreUsuario; // ✅ Agregar este parámetro
  final String avatar;

  const ServiceDetailScreen({
    Key? key,
    required this.serviceName,
    required this.serviceImage,
    required this.descripcion,
    required this.direccion,
    required this.solicitudId,
    required this.fecha,
    required this.hora,
    required this.userId,
    required this.nombreUsuario,
    required this.avatar,
  }) : super(key: key);

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
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

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  String userName = "Cargando..."; // Se inicializa con un texto de carga
  String avatarUrl = 'https://airtecs-lgfl.onrender.com/uploads/avatar-default.jpg'; // Inicializamos con el avatar por defecto

  @override
  void initState() {
    super.initState();
    getSolicitudById();
  }

  Future<void> getSolicitudById() async {
    try {
      final respuesta = await ApiService.getSolicitudById(widget.solicitudId);

      final nombre = respuesta != null && respuesta.containsKey('nombre_usuario')
          ? respuesta["nombre_usuario"] ?? "Usuario desconocido" 
          : "Usuario desconocido";

          // Manejo del avatar
    final avatar = respuesta != null && respuesta.containsKey('avatar')
        ? respuesta["avatar"]
        : null;

    // Verificar si el avatar es una URL completa o relativa
    final avatarUrl = avatar != null
        ? (avatar.startsWith('http')
            ? avatar // Si es una URL completa
            : 'https://airtecs-lgfl.onrender.com/$avatar') // Si es relativa
        : 'https://airtecs-lgfl.onrender.com/uploads/avatar-default.jpg'; // Avatar por defecto

      setState(() {
        userName = nombre;
        this.avatarUrl = avatarUrl;
      });
    } catch (error) {
      setState(() {
        userName = "Error al cargar";
        avatarUrl = 'https://airtecs-lgfl.onrender.com/uploads/avatar-default.jpg'; // Avatar por defecto en caso de error
      });
    }
  }

  Future<void> aceptarServicio() async {
  try {
    await ApiService.aceptarSolicitud(widget.solicitudId);

    // ✅ Mostrar un mensaje de éxito con diseño profesional
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 28), // Icono de éxito
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Solicitud aceptada con éxito.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green, // Color más llamativo
          behavior: SnackBarBehavior.floating, // ✅ Flotante
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // ✅ Bordes redondeados
          ),
          duration: const Duration(seconds: 3), // ✅ Se oculta después de 3 segundos
        ),
      );

      // ✅ Navegar a ServicesPage después de aceptar la solicitud
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ServicesPage()),
      );
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 28), // Icono de error
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Error al aceptar la solicitud: $error",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red, // Color de error
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Barra blanca con botón de regresar y logo (más baja)
          Container(
            padding: const EdgeInsets.fromLTRB(15, 40, 15, 10),
            height: 90,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                Image.asset(
                  'lib/assets/images/imagen.jpg',
                  width: 45,
                  height: 45,
                ),
              ],
            ),
          ),

          // 🔹 Imagen del servicio debajo de la barra blanca
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
            child: Image.asset(
              getServiceImage(widget.serviceName),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 10),

          // Avatar y Nombre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alineamos todo a la izquierda
              children: [
                // Avatar
               Container(
  width: 65,
  height: 65,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: const Color.fromARGB(255, 227, 51, 233), width: 2),
    image: DecorationImage(
      image: NetworkImage(avatarUrl), // ✅ Usando la URL procesada
      fit: BoxFit.cover,
    ),
  ),
),

                const SizedBox(height: 5), // Espacio entre el avatar y el nombre
                // Nombre debajo del avatar
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Detalles del servicio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Texto "Detalles del Servicio"
                Text(
                  "Detalles del Servicio",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 0, 0), // Color gris
                  ),
                ),
                const SizedBox(height: 5),
                // Línea gris
                Container(
                  height: 4,
                  color: Colors.grey[300], // Línea gris
                ),
                const SizedBox(height: 10),

                // Nombre del servicio
                Text(
                  widget.serviceName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                // Descripción
                const SizedBox(height: 5),
                Text(
                  widget.descripcion,
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color.fromARGB(255, 96, 96, 96),
                  ),
                ),
                const SizedBox(height: 10),

                // Fecha
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Fecha:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.fecha,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 78, 78, 78),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Hora
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Hora:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.hora,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 78, 78, 78),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Dirección
Row(
  crossAxisAlignment: CrossAxisAlignment.start, // Alinea al inicio
  children: [
    const Icon(
      Icons.location_on,
      size: 18,
      color: Color.fromARGB(255, 221, 48, 48), // Rojo
    ),
    const SizedBox(width: 5),
    Expanded( // ✅ Permite que el texto haga salto de línea
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          children: [
            const TextSpan(
              text: "Dirección: ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: widget.direccion,
              style: const TextStyle(
                color: Color.fromARGB(255, 78, 78, 78),
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),

              ],
            ),
          ),

          // Botón de "Aceptar Servicio"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50), // Añadir espacio alrededor del botón
            child: Center( // Agregamos un Center para centrar el botón
              child: ElevatedButton(
                onPressed: () {
                  // Acción al aceptar el servicio
                  aceptarServicio();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // Azul suave
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Bordes más redondeados
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40), // Aumentar espacio interno
                  elevation: 5, // Sombra para el botón
                ),
                child: const Text(
                  "Aceptar Servicio",
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 18, // Fuente un poco más grande
                    fontWeight: FontWeight.bold, // Fuente en negrita
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
