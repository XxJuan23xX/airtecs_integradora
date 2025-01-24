import 'package:flutter/material.dart';

class WidgetBottomBar extends StatelessWidget {
  const WidgetBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: "Explorar",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build),
          label: "Servicios",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Mi Cuenta",
        ),
      ],
      selectedItemColor: Colors.blue, // Color del ítem seleccionado
      unselectedItemColor: Colors.grey, // Color de los ítems no seleccionados
      showUnselectedLabels: true,
    );
  }
}
