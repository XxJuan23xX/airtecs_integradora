import 'package:flutter/material.dart';
import 'package:airtecs_movil/Services/api_service.dart';
import 'package:airtecs_movil/Features/Services_Page/Presentation/Widgets/ServiceWidget.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
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
      final data = await ApiService.getSolicitudesAceptadas();
      List<dynamic> solicitudesActualizadas = [];

      for (var solicitud in data) {
        final historialEstados = await ApiService.getHistorialEstados(solicitud["_id"].toString());

        if (historialEstados.isNotEmpty) {
          final estadoActual = historialEstados.last["estado"];
          solicitud["estado"] = estadoActual;
          solicitud["historial"] = historialEstados; // 🔥 Guardamos todo el historial
        }

        if (solicitud["estado"] != "finalizado") {
          solicitudesActualizadas.add(solicitud);
        }
      }

      setState(() {
        solicitudes = solicitudesActualizadas;
      });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Servicios Aceptados"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : solicitudes.isEmpty
              ? const Center(
                  child: Text(
                    "No tienes solicitudes aceptadas.",
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: solicitudes.length,
                  itemBuilder: (context, index) {
                    final solicitud = solicitudes[index];
                    return ServiceWidget(
                      solicitudId: solicitud["_id"].toString(),
                      estadoActual: solicitud["estado"],
                      historialEstados: solicitud["historial"] ?? [], // 🔥 Pasamos el historial
                      onEstadoActualizado: cargarSolicitudes,
                    );
                  },
                ),
    );
  }
}
