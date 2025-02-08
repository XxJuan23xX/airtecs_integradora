import 'package:flutter/material.dart';
import 'package:airtecs_movil/Features/Notifications_page/Presentation/Screens/Notification_Page.dart';
import 'package:airtecs_movil/Features/History_Page/Presentation/Screens/HIstoy_page.dart'; // ✅ Importar HistoryPage

class WidgetNavbar extends StatelessWidget {
  final String title;

  const WidgetNavbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent], // Gradiente azul
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26, // Sombra sutil
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // Redirige a la página de Notificaciones
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const NotificationPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.notifications, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  // ✅ Redirige a la pantalla de historial
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const HistoryPage(), // Asegúrate de importar esta página
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.history, color: Colors.white), // ✅ Icono de historial
              ),
            ],
          ),
        ],
      ),
    );
  }
}
