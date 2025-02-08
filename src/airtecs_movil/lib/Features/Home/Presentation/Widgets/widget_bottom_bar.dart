import 'package:flutter/material.dart';

class WidgetBottomBar extends StatelessWidget {
  final VoidCallback? onHomePressed;
  final VoidCallback? onServicesPressed;

  const WidgetBottomBar({
    Key? key,
    this.onHomePressed,
    this.onServicesPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.lightBlue], // Gradiente azul
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: NavigationBar(
        selectedIndex: 0, // Por defecto seleccionamos el primer índice
        onDestinationSelected: (index) {
          if (index == 0 && onHomePressed != null) {
            onHomePressed!(); // Ejecuta la función para Inicio
          } else if (index == 1 && onServicesPressed != null) {
            onServicesPressed!(); // Ejecuta la función para Servicios
          }
        },
        destinations: const [
          NavigationDestination(
            icon: _ShadowedIcon(icon: Icons.home), // Ícono con sombreado
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: _ShadowedIcon(icon: Icons.build), // Ícono con sombreado
            label: 'Servicios',
          ),
        ],
        backgroundColor: Colors.transparent, // Fondo transparente para mostrar el gradiente
        surfaceTintColor: Colors.transparent, // Elimina efectos de tintado
        animationDuration: const Duration(milliseconds: 500), // Animación suave
      ),
    );
  }
}

class _ShadowedIcon extends StatelessWidget {
  final IconData icon;

  const _ShadowedIcon({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Sombra con transparencia
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3), // Posición de la sombra
          ),
        ],
      ),
      child: Icon(icon, size: 28, color: Colors.white), // Ícono blanco con sombra
    );
  }
}
