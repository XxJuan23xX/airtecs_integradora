import 'package:flutter/material.dart';
import 'dart:async'; // Para programar el temporizador

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Temporizador para redirigir al Login después de 1.5 segundos
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/login');

    });

    return Scaffold(
      backgroundColor: Colors.white, // Cambia el color si deseas
      body: Center(
        child: Image.asset(
          'assets/images/navbar-logo.png', // Asegúrate de que la ruta sea correcta
          width: 150, // Tamaño del logo, ajusta si es necesario
          height: 150,
        ),
      ),
    );
  }
}
