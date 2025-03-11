import 'package:flutter/material.dart';
import 'package:airtecs_movil/Features/auth/screens/splash_screen.dart'; // Importamos SplashScreen
import 'package:airtecs_movil/Features/Welcome/Presentation/Screens/ScreenFirstWelcome.dart';
import 'package:airtecs_movil/Features/Session/Presentation/Screens/login_screen.dart';
import 'package:airtecs_movil/Features/Session/Presentation/Screens/register_screen.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Screens/HomeScreen.dart';
import 'package:airtecs_movil/features/Services_Page/Presentation/Screens/ServicesPage.dart';
import 'package:airtecs_movil/Features/Notifications_page/Presentation/Screens/Notification_Page.dart';
import 'package:flutter/services.dart'; // ✅ Importar para bloquear orientación

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 🔹 Asegura inicialización antes de ejecutar

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,   // Solo modo vertical normal
    DeviceOrientation.portraitDown, // Opcional (si quieres permitirlo boca abajo)
  ]).then((_) {
    runApp(const MyApp());
  });
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
      home: const SplashScreen(), // ✅ SplashScreen maneja la navegación inicial
      routes: {
        '/welcome': (context) => const ScreenFirstWelcome(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/services': (context) => const ServicesPage(),
        '/notifications': (context) => const NotificationPage(),
      },
    );
  }
}
