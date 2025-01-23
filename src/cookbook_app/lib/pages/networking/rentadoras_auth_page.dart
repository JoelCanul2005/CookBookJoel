import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookbook_joel/pages/networking/rentadoras_home_page.dart';
import 'dart:convert';
import 'dart:ui';

class RentadorasAuthPage extends StatefulWidget {
  const RentadorasAuthPage({super.key});

  @override
  State<RentadorasAuthPage> createState() => _RentadorasAuthPageState();
}

class _RentadorasAuthPageState extends State<RentadorasAuthPage>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool isLoading = false;
  late AnimationController _controller;

  // Controladores para los campos de texto
  final _nombreController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();

  // URL base de tu API
  final String baseUrl = 'https://apirentz2-1.onrender.com';

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nombreController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // Función para manejar el registro
  Future<void> _handleRegister() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/rentadores/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': _nombreController.text,
          'username': _usernameController.text,
          'contrasenia': _passwordController.text,
          'correo': _correoController.text,
          'telefono': _telefonoController.text,
          'imagen_perfil': '', // Puedes implementar subida de imágenes después
        }),
      );

      if (response.statusCode == 201) {
        // Registro exitoso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => isLogin = true); // Cambiar a la vista de login
      } else {
        // Error en el registro
        final error = json.decode(response.body);
        throw Exception(error['mensaje'] ?? 'Error en el registro');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Función para manejar el login
  // En rentadoras_auth_page.dart, modifica _handleLogin:
  Future<void> _handleLogin() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/rentadores/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'contrasenia': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];

        // Extraer el ID del token JWT
        String? rentadorId;
        try {
          // Dividir el token en sus partes (header.payload.signature)
          final parts = token.split('.');
          if (parts.length > 1) {
            // Decodificar el payload (segunda parte)
            final payload = json.decode(
              utf8.decode(
                base64Url.decode(
                  base64Url.normalize(parts[1]),
                ),
              ),
            );
            print('Payload del token: $payload'); // Para debug
            rentadorId = payload['id']?.toString() ?? payload['sub']?.toString();
          }
        } catch (e) {
          print('Error decodificando token: $e');
        }

        if (rentadorId == null) {
          print('No se pudo extraer el ID del token, usando ID por defecto');
          // Si no podemos obtener el ID del token, usamos el username como identificador temporal
          rentadorId = _usernameController.text;
        }

        // Guardar el token y el ID
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('rentador_id', rentadorId);

        // Log de inicio de sesión
        print('Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): ${DateTime.now().toUtc().toString()}');
        print('Current User\'s Login: ${_usernameController.text}');
        print('Rentador ID: $rentadorId');

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RentadorasHomePage()),
              (route) => false,
        );
      } else {
        final error = json.decode(response.body);
        throw Exception(error['mensaje'] ?? 'Error en el inicio de sesión');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8ECF4),
      body: Stack(
        children: [
          // Fondo con degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withOpacity(0.2),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Animación Lottie
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeOut,
                    )),
                  ),

                  const SizedBox(height: 20),

                  // Título
                  Text(
                    isLogin ? 'Bienvenido' : 'Crear Cuenta',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Formulario con efecto glassmorphism
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            if (!isLogin) ...[
                              _buildTextField(
                                controller: _nombreController,
                                hint: 'Nombre completo',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 15),
                            ],

                            _buildTextField(
                              controller: _usernameController,
                              hint: 'Username',
                              icon: Icons.account_circle_outlined,
                            ),
                            const SizedBox(height: 15),

                            if (!isLogin) ...[
                              _buildTextField(
                                controller: _correoController,
                                hint: 'Correo electrónico',
                                icon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 15),

                              _buildTextField(
                                controller: _telefonoController,
                                hint: 'Teléfono',
                                icon: Icons.phone_outlined,
                              ),
                              const SizedBox(height: 15),
                            ],

                            _buildTextField(
                              controller: _passwordController,
                              hint: 'Contraseña',
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),
                            const SizedBox(height: 25),

                            // Botón de acción
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => isLogin ? _handleLogin() : _handleRegister(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                  isLogin ? 'Iniciar Sesión' : 'Registrarse',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botón para cambiar entre login y registro
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        _controller.reset();
                        _controller.forward();
                      });
                    },
                    child: Text(
                      isLogin
                          ? '¿No tienes cuenta? Regístrate'
                          : '¿Ya tienes cuenta? Inicia sesión',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}