import 'package:flutter/material.dart';
import 'package:airtecs_movil/features/Welcome/Presentation/Screens/ScreenFirstWelcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIR TECS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ScreenFirstWelcome(), // Punto de inicio de la app
    );
  }
}
