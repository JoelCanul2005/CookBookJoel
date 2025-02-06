import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookbook_joel/pages/networking/rentadores_home_page.dart';
import 'dart:convert';
import 'dart:ui';

class RentadoresAuthPage extends StatefulWidget {
  const RentadoresAuthPage({super.key});

  @override
  State<RentadoresAuthPage> createState() => _RentadoresAuthPageState();
}

class _RentadoresAuthPageState extends State<RentadoresAuthPage>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool isLoading = false;
  late AnimationController _controller;

  // Controladores para los campos de texto
  final _nombreController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // URL base de la API
  final String baseUrl = 'https://apirentz2-1.onrender.com/api/auth';

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
    super.dispose();
  }

  // Función para manejar el registro
  Future<void> _handleRegister() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': _nombreController.text,
          'username': _usernameController.text,
          'contrasenia': _passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => isLogin = true);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['mensaje'] ?? 'Error en el registro');
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

  // Función para manejar el login
  Future<void> _handleLogin() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'contrasenia': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];

        // Guardar el token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (!mounted) return;

        // Navegar al home y remover todas las rutas anteriores
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RentadoresHomePage()),
              (route) => false,
        );
      } else {
        final error = json.decode(response.body);
        throw Exception(error['mensaje'] ?? 'Credenciales incorrectas');
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
      backgroundColor: const Color(0xFFCAA26D),
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
                    child: Image.asset(
                      'assets/images/rentz.png', // Ruta de tu imagen
                      height: 200,
                      fit: BoxFit.contain, // Ajusta la imagen al espacio disponible
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Título
                  Text(
                    isLogin ? 'Bienvenido' : 'Crear Cuenta',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(81, 27, 0, 1.0),

                    ),
                  ),

                  const SizedBox(height: 30),

                  // Formulario con efecto glassmorphism
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(202, 142, 109, 1.0),
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
                                  backgroundColor:  const Color(0xFFFFC107),
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
                                    color: Color.fromRGBO(81, 27, 0, 1.0), // Rojo anaranjado personalizado,
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
                        color: Color.fromRGBO(81, 27, 0, 1.0),
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
    // Estado para controlar si la contraseña es visible o no
    bool isPasswordVisible = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return TextField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible, // Oculta la contraseña si es un campo de contraseña y no está visible
          style: TextStyle(color: Colors.brown),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.brown),
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
              borderSide: BorderSide(color: Colors.blue),
            ),
            // Agregar el botón de ojo para mostrar/ocultar la contraseña
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black54,
              ),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            )
                : null,
          ),
        );
      },
    );
  }
}