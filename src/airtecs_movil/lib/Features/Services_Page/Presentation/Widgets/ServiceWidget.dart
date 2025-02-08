import 'package:flutter/material.dart';
import 'package:airtecs_movil/Services/api_service.dart';

class ServiceWidget extends StatefulWidget {
  final String solicitudId;
  final String estadoActual;
  final VoidCallback onEstadoActualizado;

  const ServiceWidget({
    Key? key,
    required this.solicitudId,
    required this.estadoActual,
    required this.onEstadoActualizado,
  }) : super(key: key);

  @override
  State<ServiceWidget> createState() => _ServiceWidgetState();
}

class _ServiceWidgetState extends State<ServiceWidget> {
  bool isLoading = false;
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _detallesController = TextEditingController();
  String? selectedEstado;

  final List<String> ordenEstados = ['en_camino', 'en_lugar', 'en_proceso', 'finalizado'];

  void actualizarEstado() async {
    if (selectedEstado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un estado.")),
      );
      return;
    }

    if (['en_lugar', 'finalizado'].contains(selectedEstado) && _codigoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes ingresar el código de confirmación.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.actualizarEstadoServicio(
        solicitudId: widget.solicitudId,
        estado: selectedEstado!,
        codigoConfirmacion: _codigoController.text.trim().isEmpty ? null : _codigoController.text.trim(),
        detalles: _detallesController.text.trim().isEmpty ? null : _detallesController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Estado actualizado correctamente.")),
      );

      widget.onEstadoActualizado.call();
      Navigator.pop(context);
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
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => _buildBottomSheet(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Solicitud #${widget.solicitudId}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.circle, size: 12, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    "Estado: ${widget.estadoActual.replaceAll("_", " ").toUpperCase()}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => _buildBottomSheet(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    "Actualizar Estado",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Actualizar Estado del Servicio",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedEstado,
            onChanged: (value) {
              setState(() {
                selectedEstado = value;
              });
            },
            items: ordenEstados.map((estado) {
              return DropdownMenuItem(
                value: estado,
                child: Text(estado.replaceAll("_", " ").toUpperCase()),
              );
            }).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              labelText: "Selecciona el nuevo estado",
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 10),
          if (selectedEstado == "en_lugar" || selectedEstado == "finalizado")
            TextField(
              controller: _codigoController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelText: "Código de Confirmación",
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          const SizedBox(height: 10),
          TextField(
            controller: _detallesController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              labelText: "Detalles adicionales (opcional)",
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 20),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: actualizarEstado,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Confirmar",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
