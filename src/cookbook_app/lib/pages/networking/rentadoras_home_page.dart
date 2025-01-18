import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RentadorasHomePage extends StatefulWidget {
  const RentadorasHomePage({super.key});

  @override
  State<RentadorasHomePage> createState() => _RentadorasHomePageState();
}

class _RentadorasHomePageState extends State<RentadorasHomePage> {
  List<Map<String, dynamic>> productos = [];
  bool isLoading = true;
  final String baseUrl = 'https://apirentz2-1.onrender.com';

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> cargarProductos() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No hay token de autenticación');

      final response = await http.get(
        Uri.parse('$baseUrl/api/productos/rentador/misproductos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          productos = data.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar productos');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> eliminarProducto(int id) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No hay token de autenticación');

      final response = await http.delete(
        Uri.parse('$baseUrl/api/productos/delete/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          productos.removeWhere((producto) => producto['id'] == id);
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado con éxito')),
        );
      } else {
        throw Exception('Error al eliminar el producto');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : productos.isEmpty
          ? const Center(child: Text('No hay productos registrados'))
          : ListView.builder(
        itemCount: productos.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final producto = productos[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: producto['imagen_principal'] != null
                  ? CircleAvatar(
                backgroundImage: NetworkImage(
                  producto['imagen_principal'],
                ),
              )
                  : const CircleAvatar(
                child: Icon(Icons.image),
              ),
              title: Text(producto['nombre']),
              subtitle: Text(
                'Precio: \$${producto['precio']}\n'
                    'Disponibles: ${producto['cantidad_disponible']}',
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Editar'),
                      onTap: () {
                        Navigator.pop(context);
                        // Implementar edición
                        _mostrarFormularioEdicion(producto);
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Eliminar'),
                      onTap: () {
                        Navigator.pop(context);
                        eliminarProducto(producto['id']);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioAgregar(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _mostrarFormularioAgregar() async {
    // Implementar formulario para agregar producto
  }

  Future<void> _mostrarFormularioEdicion(Map<String, dynamic> producto) async {
    // Implementar formulario para editar producto
  }
}