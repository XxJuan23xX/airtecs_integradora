import 'package:flutter/material.dart';

class WidgetBottomBar extends StatelessWidget {
  final VoidCallback? onHomePressed;
  final VoidCallback? onServicesPressed;
  final VoidCallback? onProfilePressed;
  final int selectedIndex; // 🔥 Índice dinámico para la página actual

  const WidgetBottomBar({
    Key? key,
    this.onHomePressed,
    this.onServicesPressed,
    this.onProfilePressed,
    required this.selectedIndex, // 🔥 Recibe el índice actual
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            icon: Icons.explore,
            label: "Explorar",
            isActive: selectedIndex == 0, // 🔥 Activo si el índice es 0
            onTap: onHomePressed,
          ),
          _buildNavItem(
            icon: Icons.store,
            label: "Servicios",
            isActive: selectedIndex == 1, // 🔥 Activo si el índice es 1
            onTap: onServicesPressed,
          ),
          _buildNavItem(
            icon: Icons.person,
            label: "Mi Cuenta",
            isActive: selectedIndex == 2, // 🔥 Activo si el índice es 2
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
            color: isActive ? Colors.blue : Colors.grey, // 🔥 Se ilumina según la página activa
          ),
          const SizedBox(height: 4),
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
