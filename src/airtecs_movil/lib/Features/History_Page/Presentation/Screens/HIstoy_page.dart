import 'package:flutter/material.dart';
import 'package:airtecs_movil/Services/api_service.dart';
import 'package:airtecs_movil/Features/Services_Page/Presentation/Screens/ServiceDetailScreen.dart';
import 'package:airtecs_movil/Features/History_Page/Presentation/Screens/HistoryDetailScreen.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<dynamic>> _serviciosFinalizados;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startFakeLoading(); // 🔥 Inicia la animación de la barra
    _serviciosFinalizados = ApiService.getSolicitudesPagadas();
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
      body: FutureBuilder<List<dynamic>>(
        future: _serviciosFinalizados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Cargando historial...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), // 🔥 Bordes redondeados para más estilo
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 10,
                      backgroundColor: Colors.blue[100], // 🔹 Color de fondo "hielo"
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent), // 🔹 Color de llenado
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay servicios finalizados.'));
          }

          final servicios = snapshot.data!;
          
          return ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: servicios.length,
  itemBuilder: (context, index) {
    final servicio = servicios[index];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color.fromARGB(255, 248, 248, 248),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Nombre del Servicio
            Text(
              servicio["tipo_servicio"] ?? "Servicio Desconocido",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),

            // 🔹 Cliente que solicitó el servicio
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey, size: 18),
                const SizedBox(width: 5),
                Text(
                  servicio["nombre_usuario"] ?? "Cliente desconocido",
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // 🔹 Dirección del servicio
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 18),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    servicio["direccion"] ?? "Dirección no disponible",
                    softWrap: true,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // 🔹 Fecha del servicio
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.green, size: 18),
                const SizedBox(width: 5),
                Text(
                  servicio["fecha"] ?? "Fecha desconocida",
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 5),

            // 🔹 Hora del servicio
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange, size: 18),
                const SizedBox(width: 5),
                Text(
                  servicio["hora"] ?? "Hora no registrada",
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),

            const Divider(thickness: 1.2, height: 20),

            

            // 🔹 Botón para ver detalles
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryDetailScreen(
                      solicitudId: servicio["_id"] ?? "",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: const Text("Ver Detalles", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  },
);
        })
      );
  }
}


