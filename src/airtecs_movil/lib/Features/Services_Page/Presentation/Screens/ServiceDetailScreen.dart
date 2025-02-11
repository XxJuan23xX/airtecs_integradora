import 'package:flutter/material.dart';
import 'package:airtecs_movil/Services/api_service.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String serviceName;
  final String serviceImage;
  final String descripcion;
  final String direccion;
  final String solicitudId;
  final String fecha;
  final String hora;

  const ServiceDetailScreen({
    Key? key,
    required this.serviceName,
    required this.serviceImage,
    required this.descripcion,
    required this.direccion,
    required this.solicitudId,
    required this.fecha,
    required this.hora,
  }) : super(key: key);

  Future<void> aceptarSolicitud(BuildContext context) async {
    try {
      await ApiService.aceptarSolicitud(solicitudId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud aceptada con éxito.')),
      );
      Navigator.pop(context); // Volver a la lista de solicitudes
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aceptar: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3), // Fondo gris claro para mayor contraste
      appBar: AppBar(
  title: const Text(
    "Detalles del Servicio",
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  backgroundColor: Colors.blueAccent,
  foregroundColor: Colors.white,
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Imagen del servicio
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                serviceImage,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Tarjeta de detalles
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descripcion,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const Divider(height: 30, thickness: 1.2),

                  // 🔹 Dirección
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          direccion,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 🔹 Fecha y Hora
                  Row(
                    children: [
                      const Icon(Icons.date_range, color: Colors.blueAccent, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Fecha: $fecha",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.green, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Hora: $hora",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Botón Aceptar Servicio
            ElevatedButton(
              onPressed: () => aceptarSolicitud(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text(
                "Aceptar Servicio",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
