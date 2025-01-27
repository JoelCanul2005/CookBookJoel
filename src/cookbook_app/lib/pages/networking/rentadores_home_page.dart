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
  List<dynamic> productosFiltrados = [];
  bool isLoading = false;
  int currentPage = 1;
  final int limit = 10;
  bool hasMoreProducts = true;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  // Airbnb style colors
  static const Color primaryColor = Color(0xFFFF5A5F);
  static const Color secondaryColor = Color(0xFF00A699);
  static const Color backgroundColor = Color(0xFFF7F7F7);
  static const Color textColor = Color(0xFF484848);

  // Airbnb style text themes
  final TextStyle titleStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: 0.3,
  );

  final TextStyle subtitleStyle = const TextStyle(
    fontSize: 16,
    color: Colors.grey,
    letterSpacing: 0.2,
  );

  final TextStyle priceStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryColor,
  );

  @override
  void initState() {
    super.initState();
    fetchProductos();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        productosFiltrados = List.from(productos);
      } else {
        productosFiltrados = productos.where((producto) {
          final nombre = producto['nombre'].toString().toLowerCase();
          final descripcion = producto['descripcion'].toString().toLowerCase();
          return nombre.contains(query) || descripcion.contains(query);
        }).toList();
      }
    });
  }
  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMoreProducts && !isSearching) {
        fetchProductos(page: currentPage + 1);
      }
    }
  }

  Future<void> fetchProductos({int page = 1}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) throw Exception('No se encontró el token de autenticación');

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
            productosFiltrados = List.from(productos);
          } else {
            productos.addAll(data['productos']);
            productosFiltrados = List.from(productos);
          }
          currentPage = page;
          hasMoreProducts = data['productos'].length == limit;
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        throw Exception('Error al cargar los productos');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  Future<void> _refreshProductos() async {
    currentPage = 1;
    hasMoreProducts = true;
    _searchController.clear();
    await fetchProductos();
  }

  String formatPrice(dynamic price) {
    if (price == null) return '0.00';
    if (price is String) {
      try {
        return double.parse(price).toStringAsFixed(2);
      } catch (e) {
        return '0.00';
      }
    }
    if (price is int) return price.toDouble().toStringAsFixed(2);
    if (price is double) return price.toStringAsFixed(2);
    return '0.00';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: !isSearching
            ? Text('Explora Productos', style: titleStyle)
            : TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar productos...',
            hintStyle: subtitleStyle,
            border: InputBorder.none,
          ),
          style: TextStyle(color: textColor),
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: textColor),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  _searchController.clear();
                  productosFiltrados = List.from(productos);
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: textColor),
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
        color: primaryColor,
        child: productosFiltrados.isEmpty && !isLoading
            ? Center(
          child: Text('No hay productos disponibles', style: subtitleStyle),
        )
            : GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: productosFiltrados.length + (isLoading && !isSearching ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == productosFiltrados.length) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            final producto = productosFiltrados[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Esta es la parte que muestra la imagen desde la API
                  Container(
                    height: 150, // Aumentamos un poco la altura para mejor visualización
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: producto['imagen_principal'] != null
                          ? Image.network(
                        producto['imagen_principal'],
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              color: secondaryColor,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return Container(
                            color: secondaryColor.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: secondaryColor.withOpacity(0.5),
                              ),
                            ),
                          );
                        },
                      )
                          : Container(
                        color: secondaryColor.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: secondaryColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto['nombre'] ?? 'Sin nombre',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          producto['descripcion'] ?? 'Sin descripción',
                          style: subtitleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${formatPrice(producto['precio'])}',
                              style: priceStyle,
                            ),
                            IconButton(
                              icon: const Icon(Icons.shopping_cart, color: primaryColor),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${producto['nombre']} agregado al carrito'),
                                    backgroundColor: primaryColor,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Carrito de compras próximamente'),
              backgroundColor: primaryColor,
            ),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.shopping_cart_checkout),
      ),
    );
  }
}