import 'package:flutter/material.dart';

class WidgetBottomBar extends StatelessWidget {
  final VoidCallback? onHomePressed;
  final VoidCallback? onServicesPressed;
  final VoidCallback? onProfilePressed;

  const WidgetBottomBar({
    Key? key,
    this.onHomePressed,
    this.onServicesPressed,
    this.onProfilePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65, // 🔹 Reduce el alto total de la barra
      decoration: const BoxDecoration(
        color: Colors.white, // 🔹 Fondo igual que la pantalla
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 🔹 Asegura que los elementos estén equidistantes
        children: [
          _buildNavItem(
            icon: Icons.explore,
            label: "Explorar",
            isActive: true, // 🔹 Puedes cambiar esto dinámicamente según la página actual
            onTap: onHomePressed,
          ),
          _buildNavItem(
            icon: Icons.store,
            label: "Servicios",
            isActive: false,
            onTap: onServicesPressed,
          ),
          _buildNavItem(
            icon: Icons.person,
            label: "Mi Cuenta",
            isActive: false,
            onTap: onProfilePressed,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? Colors.blue : Colors.grey, // 🔹 Color azul si está activo, gris si no
          ),
          const SizedBox(height: 4), // 🔹 Espaciado entre el icono y el texto
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
