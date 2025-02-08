import 'package:flutter/material.dart';
import 'package:airtecs_movil/Services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<dynamic>> _serviciosFinalizados;

  @override
  void initState() {
    super.initState();
    _serviciosFinalizados = ApiService.getServiciosFinalizados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _serviciosFinalizados,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay servicios finalizados disponibles.'));
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
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    'ID Solicitud: ${servicio["solicitud_id"]}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estado: ${servicio["estado"]}'),
                      Text('Detalles: ${servicio["detalles"] ?? "Sin detalles"}'),
                      Text('Fecha: ${servicio["timestamp"]}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
