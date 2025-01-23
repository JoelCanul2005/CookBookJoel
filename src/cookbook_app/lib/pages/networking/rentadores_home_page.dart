import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RentadoresHomePage extends StatefulWidget {
  const RentadoresHomePage({super.key});

  @override
  State<RentadoresHomePage> createState() => _RentadoresHomePageState();
}

class _RentadoresHomePageState extends State<RentadoresHomePage> {
  final String baseUrl = 'https://apirentz2-1.onrender.com/api/productos';
  List<dynamic> productos = [];
  bool isLoading = false;
  int currentPage = 1;
  final int limit = 10;
  bool hasMoreProducts = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchProductos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMoreProducts) {
        fetchProductos(page: currentPage + 1);
      }
    }
  }

  Future<void> fetchProductos({int page = 1}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No se encontró el token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$baseUrl?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (page == 1) {
            productos = data['productos'];
          } else {
            productos.addAll(data['productos']);
          }
          currentPage = page;
          hasMoreProducts = data['productos'].length == limit;
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Token expirado o inválido
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        throw Exception('Error al cargar los productos');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _refreshProductos() async {
    currentPage = 1;
    hasMoreProducts = true;
    await fetchProductos();
  }

  // Función auxiliar para formatear el precio
  String formatPrice(dynamic price) {
    if (price == null) return '0.00';

    // Si es String, convertir a double
    if (price is String) {
      try {
        return double.parse(price).toStringAsFixed(2);
      } catch (e) {
        return '0.00';
      }
    }

    // Si es int, convertir a double
    if (price is int) {
      return price.toDouble().toStringAsFixed(2);
    }

    // Si es double, usar directamente
    if (price is double) {
      return price.toStringAsFixed(2);
    }

    return '0.00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProductos,
        child: productos.isEmpty && !isLoading
            ? const Center(
          child: Text('No hay productos disponibles'),
        )
            : ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: productos.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == productos.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final producto = productos[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  producto['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(producto['descripcion'] ?? 'Sin descripción'),
                    const SizedBox(height: 4),
                    Text(
                      'Precio: \$${formatPrice(producto['precio'])}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${producto['nombre']} agregado al carrito'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar navegación al carrito de compras
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Carrito de compras próximamente'),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.shopping_cart_checkout),
      ),
    );
  }
}