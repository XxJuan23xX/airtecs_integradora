import 'package:flutter/material.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_navbar.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_bottom_bar.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Screens/HomeScreen.dart';
import 'package:airtecs_movil/Features/Services_Page/Presentation/Screens/ServicesPage.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: const WidgetNavbar(title: "Notificaciones"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tus notificaciones",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Número de notificaciones de ejemplo
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.blue),
                      title: Text("Notificación ${index + 1}"),
                      subtitle: Text(
                        "Esta es una descripción breve de la notificación ${index + 1}.",
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Abriste la notificación ${index + 1}."),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WidgetBottomBar(
        onHomePressed: () {
          // Redirige a HomeScreen
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
        onServicesPressed: () {
          // Redirige a ServicesPage
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ServicesPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
