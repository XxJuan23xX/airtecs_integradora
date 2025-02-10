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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _phoneError;

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

    // Validación del teléfono antes de continuar
    if (_phoneController.text.length != 10) {
      setState(() {
        _phoneError = "El número debe tener exactamente 10 dígitos";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordsMatch = true;
      _phoneError = null;
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  "lib/assets/images/logo.png",
                  height: 90,
                ),
                const SizedBox(height: 20),

                // Título
                Text(
                  "Create Account",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                // Subtítulo
                Text(
                  "Register to continue using the app",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),

                // Campos de Registro con nuevo diseño
                _buildTextField(
                  controller: _nameController,
                  label: "Full Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  icon: Icons.lock,
                  isPassword: true,
                  isConfirmPassword: true,
                  errorText: _passwordsMatch ? null : "Passwords do not match",
                ),
                const SizedBox(height: 15),

                _buildTextField(
                  controller: _specialtyController,
                  label: "Specialty",
                  icon: Icons.work,
                ),
                const SizedBox(height: 15),

                // Campo de Teléfono con validación
                _buildTextField(
                  controller: _phoneController,
                  label: "Phone",
                  icon: Icons.phone,
                  isPhone: true,
                  errorText: _phoneError,
                ),
                const SizedBox(height: 30),

                // Botón de Registro
                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF3276E8))
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3276E8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 20),

                // Opción para iniciar sesión
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        "Log In",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3276E8),
                        ),
                      ),
                    ),
                  ],
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
    bool isConfirmPassword = false,
    bool isPhone = false,
    String? errorText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        obscureText: isPassword ? (isConfirmPassword ? _obscureConfirmPassword : _obscurePassword) : false,
        keyboardType: isPhone ? TextInputType.number : TextInputType.text,
        maxLength: isPhone ? 10 : null,
        style: GoogleFonts.poppins(color: Colors.black),
        decoration: InputDecoration(
          counterText: "", // Oculta el contador de caracteres
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.black.withOpacity(0.6),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // 🔹 Sin bordes
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          prefixIcon: Icon(icon, color: const Color(0xFF3276E8)), // 🔹 Íconos azul
          errorText: errorText,
        ),
      ),
    );
  }
}
