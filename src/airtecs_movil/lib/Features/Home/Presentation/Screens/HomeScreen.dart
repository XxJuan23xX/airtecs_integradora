import 'package:flutter/material.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_bottom_bar.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_navbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: const WidgetNavbar(title: "AIR TECS"), // Ahora acepta título
      ),
      body: Center( // Centra todo el contenido
        child: Column(
          mainAxisSize: MainAxisSize.min, // Centra verticalmente
          children: [
            ElevatedButton(
              onPressed: () {
                // Acción para cargar solicitudes
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text("Cargar solicitudes"),
            ),
            const SizedBox(height: 20), // Espacio entre el botón y el texto
            const Text(
              "Cargando solicitudes...",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const WidgetBottomBar(),
    );
  }
}
