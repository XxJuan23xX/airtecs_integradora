import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:airtecs_movil/Features/Notifications_page/Presentation/Screens/Notification_Page.dart';
import 'package:airtecs_movil/Features/History_Page/Presentation/Screens/HIstoy_page.dart';

class WidgetNavbar extends StatelessWidget {
  const WidgetNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10, // Ajuste para la barra de estado
        left: 20,
        right: 20,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo centrado con imagen
          Row(
            children: [
              Image.asset(
                'lib/assets/images/imagen.jpg',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 8),
              Image.asset(
                'lib/assets/images/logo.png',
                height: 35,
              ),
            ],
          ),
          // Iconos con FontAwesome para mejor diseño
          Row(
            children: [
              IconButton(
                onPressed: () {
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
                icon: const FaIcon(FontAwesomeIcons.bell, color: Colors.black, size: 22), // Ícono de campana
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const HistoryPage(),
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
                icon: const FaIcon(FontAwesomeIcons.clock, color: Colors.black, size: 22), // Ícono de reloj
              ),
            ],
          ),
        ],
      ),
    );
  }
}
