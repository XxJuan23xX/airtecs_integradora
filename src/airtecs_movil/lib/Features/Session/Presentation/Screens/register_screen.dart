import 'package:flutter/material.dart';
import 'package:airtecs_movil/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _passwordsMatch = true;

  void _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordsMatch = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Las contraseñas no coinciden'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordsMatch = true;
    });

    try {
      final data = {
        'nombre_usuario': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'especialidad': _specialtyController.text.trim(),
        'telefono': _phoneController.text.trim(),
      };

      final response = await ApiService.registerTecnico(data);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response['mensaje']),
        backgroundColor: Colors.green,
      ));

      // ✅ Redirigir al login después de registrar
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              Color(0xFF6A11CB), // Morado oscuro
              Color(0xFF2575FC), // Azul brillante
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Botón de retroceso
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Regresar a la pantalla anterior
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Crea tu cuenta',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nombre de usuario',
                  icon: Icons.person,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _emailController,
                  label: 'Correo electrónico',
                  icon: Icons.email,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  icon: Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar contraseña',
                  icon: Icons.lock,
                  isPassword: true,
                  errorText: _passwordsMatch ? null : 'Las contraseñas no coinciden',
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _specialtyController,
                  label: 'Especialidad',
                  icon: Icons.work,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  icon: Icons.phone,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Botón blanco
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5, // Sombra sutil
                        ),
                        child: Text(
                          'Registrarse',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2575FC), // Texto azul
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    '¿Ya tienes una cuenta? Inicia sesión',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white, // Texto blanco
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? errorText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Fondo blanco semi-transparente
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.poppins(color: Colors.black), // Texto negro
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.black.withOpacity(0.6), // Label gris oscuro
          ),
          border: InputBorder.none, // Sin borde
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.6)),
          errorText: errorText,
          errorStyle: GoogleFonts.poppins(color: Colors.red), // Texto de error en rojo
        ),
      ),
    );
  }
}