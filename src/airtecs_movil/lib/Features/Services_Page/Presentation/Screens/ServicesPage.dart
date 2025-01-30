import 'package:flutter/material.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_bottom_bar.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_navbar.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Screens/HomeScreen.dart'; // Importar HomeScreen

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: const WidgetNavbar(title: "Servicios"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Servicios disponibles",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Aquí puedes explorar los servicios disponibles.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WidgetBottomBar(
        onHomePressed: () {
          // Redirige al HomeScreen con una animación personalizada
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Animación de deslizamiento
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        },
        onServicesPressed: () {
          // Mantener en la misma página de servicios
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ya estás en la página de servicios.')),
          );
        },
      ),
    );
  }
}
