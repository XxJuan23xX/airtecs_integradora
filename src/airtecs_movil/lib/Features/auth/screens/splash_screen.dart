import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Screens/HomeScreen.dart';
import 'package:airtecs_movil/Features/Session/Presentation/Screens/login_screen.dart';
import 'package:airtecs_movil/Features/Welcome/Presentation/Screens/ScreenFirstWelcome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Configurar animación de Fade-in y Scale-in
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward(); // Iniciar animación

    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
    final String? token = prefs.getString('session_token');

    await Future.delayed(const Duration(seconds: 2)); // Espera 2 segundos

    if (!mounted) return;

    Future.microtask(() {
      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => hasSeenWelcome ? const LoginScreen() : const ScreenFirstWelcome(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Limpiar animación cuando se destruye el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FF), // ✅ Color de fondo basado en tu imagen
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'lib/assets/images/imagen.jpg',
              width: 150,
              height: 150,
            ),
          ),
        ),
      ),
    );
  }
}
