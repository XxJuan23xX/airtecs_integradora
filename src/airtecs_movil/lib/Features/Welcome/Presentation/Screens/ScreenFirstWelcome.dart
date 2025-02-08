import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:airtecs_movil/features/Home/Presentation/Screens/HomeScreen.dart';
import 'package:airtecs_movil/features/Session/Presentation/Screens/login_screen.dart';
import 'package:airtecs_movil/features/Session/Presentation/Screens/register_screen.dart';

class ScreenFirstWelcome extends StatefulWidget {
  const ScreenFirstWelcome({super.key});

  @override
  State<ScreenFirstWelcome> createState() => _ScreenFirstWelcome();
}

class _ScreenFirstWelcome extends State<ScreenFirstWelcome> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  Future<void> completeWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcome', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F4FC), // Azul claro
              Color(0xFFFFFFFF), // Blanco
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildSlide(
                    image: "lib/assets/images/slide1.png",
                    title: "Bienvenido",
                    description: "Descubre los mejores técnicos para tu servicio.",
                  ),
                  _buildSlide(
                    image: "lib/assets/images/slide2.png",
                    title: "Búsquedas rápidas y por ubicación",
                    description: "Obtén búsquedas rápidas en tus servicios domiciliarios.",
                  ),
                  _buildSlide(
                    image: "lib/assets/images/slide3.png",
                    title: "Confianza y Seguridad",
                    description: "Trabajamos con los mejores técnicos certificados.",
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                children: [
                  // Indicadores de página
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index ? Colors.blue : Colors.blue.withOpacity(0.3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  // Botón principal
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == 2) {
                        completeWelcome();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Botón azul
                      foregroundColor: Colors.white, // Texto blanco
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      _currentPage == 2 ? "¡Comenzar!" : "Siguiente",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Botón para ir al login
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Iniciar sesión",
                      style: TextStyle(
                        color: Colors.blue, // Texto azul
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Botón para ir al registro
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "Registrarse",
                      style: TextStyle(
                        color: Colors.blue, // Texto azul
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required String image,
    required String title,
    required String description,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              "lib/assets/images/logo.png",
              height: 100,
            ),
            const SizedBox(height: 20),
            Image.asset(image, height: 250),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Texto negro para mejor contraste
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87, // Texto negro semi-transparente
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}