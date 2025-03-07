import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:airtecs_movil/Services/api_service.dart';
import 'package:airtecs_movil/Features/Session/Presentation/Screens/login_screen.dart';
import 'package:airtecs_movil/Features/Home/Presentation/Widgets/widget_bottom_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? tecnicoData;
  File? _imageFile; // Imagen seleccionada

  @override
  void initState() {
    super.initState();
    obtenerPerfil();
  }

  Future<void> obtenerPerfil() async {
    final perfil = await ApiService.getPerfilTecnico();
    if (perfil != null) {
      setState(() {
        tecnicoData = perfil;
      });
    }
  }

  // ✅ Obtiene la URL del avatar
  String _getAvatarUrl() {
    if (tecnicoData?['avatar'] != null && tecnicoData?['avatar'].startsWith('http')) {
      return tecnicoData?['avatar'];
    } else {
      return 'https://airtecs-lgfl.onrender.com/${tecnicoData?['avatar'] ?? 'uploads/avatar-default.jpg'}';
    }
  }

  // ✅ Seleccionar imagen de la galería
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadAvatar(pickedFile.path);
    }
  }

  // ✅ Subir nueva imagen de avatar
  Future<void> _uploadAvatar(String filePath) async {
    final response = await ApiService.updateTecnicoAvatar(filePath);
    if (response != null) {
      setState(() {
        tecnicoData?['avatar'] = response['avatarUrl'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Avatar actualizado correctamente")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al actualizar el avatar")),
      );
    }
  }

  Future<void> cerrarSesion() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // 🔹 Avatar con botón de edición
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!) as ImageProvider
                    : NetworkImage(_getAvatarUrl()),
              ),
              // 🔹 Botón de edición (cámara)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue, //255, 33, 150, 243
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 🔹 Nombre del técnico
          Text(
            tecnicoData?['nombre_usuario'] ?? "Cargando...",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          // 🔹 Email del técnico
          Text(
            tecnicoData?['email'] ?? "Cargando...",
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),

          // 🔹 Especialidad y teléfono
          Text(
            "Especialidad: ${tecnicoData?['especialidad'] ?? 'Cargando...'}",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 5),
          Text(
            "+${tecnicoData?['telefono'] ?? 'Cargando...'}",
            style: const TextStyle(fontSize: 15, color: Colors.blueAccent),
          ),
          const SizedBox(height: 15),

          // 🔹 Botón Editar Perfil
          ElevatedButton(
            onPressed: () {
              // Acción para editar perfil
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child: const Text("Editar Perfil", style: TextStyle(color: Colors.white, fontSize: 15)),
          ),
          const SizedBox(height: 10),

          // 🔹 Línea divisoria
          Container(height: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),

          // 🔹 Opciones de configuración
          _buildMenuOption(Icons.notifications, "Notificaciones"),
          _buildMenuOption(Icons.history, "Historial de servicios"),
          _buildMenuOption(Icons.article, "Términos y Condiciones"),
          _buildMenuOption(Icons.logout, "Cerrar Sesión", cerrarSesion),
        ],
      ),
      bottomNavigationBar: WidgetBottomBar(
        selectedIndex: 2, // 🔥 Si estás en la página de perfil, pasa 2
        onHomePressed: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
        onServicesPressed: () {
          Navigator.pushNamed(context, '/services');
        },
        onProfilePressed: () {
          // ✅ Aquí agregamos la navegación a la pantalla de perfil
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String text, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.black54),
            ),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
