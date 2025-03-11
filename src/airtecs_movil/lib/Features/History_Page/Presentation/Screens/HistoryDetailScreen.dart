import 'package:flutter/material.dart';
import 'package:airtecs_movil/Services/api_service.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String solicitudId;

  const HistoryDetailScreen({Key? key, required this.solicitudId}) : super(key: key);

  @override
  _HistoryDetailScreenState createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  Map<String, dynamic>? solicitudDetalles;
  bool isLoading = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startFakeLoading(); // 🔥 Inicia la animación de la barra
    cargarDetalles();
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


  Future<void> cargarDetalles() async {
    final data = await ApiService.getSolicitudPagadaById(widget.solicitudId);

    if (mounted) {
      setState(() {
        solicitudDetalles = data;
        isLoading = false;
      });
    }
  }

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
                  "Cargando detalles...",
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
          : solicitudDetalles == null
              ? const Center(child: Text("Error al cargar los detalles"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        solicitudDetalles!['tipo_servicio'] ?? 'Servicio Desconocido',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      Row(
            children: [
              Text(
                solicitudDetalles!['nombre_usuario'] ?? 'Cliente Desconocido',
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
            getAvatarUrl(solicitudDetalles!['avatar']), // ✅ Usando la función para obtener la URL correcta
          ),
          fit: BoxFit.cover,
        ),
      ),
              ),
            ],
          ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              solicitudDetalles!['direccion'] ?? 'Dirección no disponible',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.green),
                          const SizedBox(width: 10),
                          Text(
                            "Fecha: ${solicitudDetalles!['fecha'] ?? 'No disponible'}",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.orange),
                          const SizedBox(width: 10),
                          Text(
                            "Hora: ${solicitudDetalles!['hora'] ?? 'No disponible'}",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Text(
                        "Detalles del servicio:",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        solicitudDetalles!['detalles'] ?? 'Sin detalles',
                        style: const TextStyle(fontSize: 15),
                      ),

                      const Divider(thickness: 1.5, height: 30),

                      // 🔹 Sección de Pago
                      const Text(
                        "Detalles del Pago",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.green),
                          const SizedBox(width: 10),
                          Text(
                            "Monto: \$${solicitudDetalles!['monto'] ?? '0.00'}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.payment, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text(
                            "Método: ${solicitudDetalles!['metodo_pago'] ?? 'No especificado'}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.green),
                          const SizedBox(width: 10),
                          Text(
                            "Estado del pago: ${solicitudDetalles!['estado_pago'] ?? 'No confirmado'}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
