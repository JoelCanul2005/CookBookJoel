import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:cookbook_joel/pages/networking/producto_form.dart';


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
    bool confirmar = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este producto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    ) ?? false;

    if (!confirmar) return;

    // Mostrar indicador de carga
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final token = await getToken();
      if (token == null) throw Exception('No hay token de autenticación');

      final response = await http.delete(
        Uri.parse('$baseUrl/api/productos/delete/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Cerrar el indicador de carga
      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        setState(() {
          productos.removeWhere((producto) => producto['id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto eliminado con éxito'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Registrar la eliminación
        print('Producto ID:$id eliminado el: ${DateTime.now().toUtc().toString()}');
        print('Usuario: JoelCanul2005');

      } else {
        throw Exception('Error al eliminar el producto');
      }
    } catch (e) {
      // Cerrar el indicador de carga si hubo un error
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
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

  // En rentadoras_home_page.dart, actualiza el método _mostrarFormularioAgregar:

  Future<void> _mostrarFormularioAgregar() async {
    // Primero verificamos si hay productos para obtener el rentador_id
    if (productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo obtener el ID del rentador'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Obtenemos el rentador_id del primer producto
    final rentadorId = productos[0]['rentador_id'];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Agregar Producto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ProductoForm(
                onSubmit: (productoData) async {
                  try {
                    final token = await getToken();
                    if (token == null) throw Exception('No hay token de autenticación');

                    // Agregamos el rentador_id a los datos del producto
                    final dataToSend = {
                      ...productoData,
                      'rentador_id': rentadorId,
                    };

                    print('Enviando datos: ${json.encode(dataToSend)}'); // Debug

                    final response = await http.post(
                      Uri.parse('$baseUrl/api/productos/agregar'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                      body: json.encode(dataToSend),
                    );

                    print('Status code: ${response.statusCode}'); // Debug
                    print('Response body: ${response.body}'); // Debug

                    if (response.statusCode == 201) {
                      if (!mounted) return;
                      Navigator.pop(context);
                      cargarProductos(); // Recargar la lista
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Producto agregado con éxito'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Log de la operación
                      print('Producto agregado el: ${DateTime.now().toUtc().toString()}');
                      print('Usuario: JoelCanul2005');
                    } else {
                      final errorResponse = json.decode(response.body);
                      throw Exception(errorResponse['error'] ?? 'Error al agregar el producto');
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarFormularioEdicion(Map<String, dynamic> producto) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Editar Producto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ProductoForm(
                producto: producto,
                onSubmit: (productoData) async {
                  try {
                    final token = await getToken();
                    if (token == null) throw Exception('No hay token de autenticación');

                    print('Enviando datos de actualización: ${json.encode(productoData)}'); // Debug

                    final response = await http.put(
                      Uri.parse('$baseUrl/api/productos/update/${producto['id']}'),
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                      body: json.encode(productoData),
                    );

                    print('Status code: ${response.statusCode}'); // Debug
                    print('Response body: ${response.body}'); // Debug

                    if (response.statusCode == 200) {
                      if (!mounted) return;
                      Navigator.pop(context);
                      cargarProductos();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Producto actualizado con éxito'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Registro de la operación
                      print('Producto actualizado el: ${DateTime.now().toUtc().toString()}');
                      print('Usuario: JoelCanul2005');
                    } else {
                      throw Exception('Error ${response.statusCode}: ${response.body}');
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}