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

  // Colores del tema
  static const Color primaryColor = Color(0xFF511B00);
  static const Color secondaryColor = Color(0xFF8B4513);
  static const Color accentColor = Color(0xFFDDD9C6);
  static const Color backgroundColor = Color(0xFFF5F2E8);
  static const Color textColor = Color(0xFF2C1810);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Estilos de texto
  final TextStyle titleStyle = const TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: primaryColor,
    letterSpacing: 0.5,
    fontFamily: 'Playfair Display',
  );

  final TextStyle subtitleStyle = const TextStyle(
    fontSize: 14,
    color: secondaryColor,
    letterSpacing: 0.3,
    fontWeight: FontWeight.w500,
  );

  final TextStyle priceStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: primaryColor,
    fontFamily: 'Playfair Display',
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
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
        backgroundColor: cardColor,
        title: !isSearching
        ? Text('Explora Productos', style: titleStyle)
        : TextField(
    controller: _searchController,
    decoration: InputDecoration(
    hintText: 'Buscar productos...',
    hintStyle: TextStyle(
    color: secondaryColor.withOpacity(0.7),
    fontSize: 16,
    ),
    border: InputBorder.none,
    ),
    style: TextStyle(color: primaryColor),
    autofocus: true,
    ),
    actions: [
    IconButton(
    icon: Icon(
    isSearching ? Icons.close : Icons.search,
    color: primaryColor,
    ),
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
    icon: Icon(Icons.exit_to_app, color: primaryColor),
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
    childAspectRatio: 0.7,
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
    return Container(
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
    BoxShadow(
    color: primaryColor.withOpacity(0.1),
    spreadRadius: 1,
    blurRadius: 10,
    offset: const Offset(0, 4),
    ),
    ],
    ),
    child: Card(
    elevation: 0,
    color: cardColor,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Stack(
    children: [
    Container(
    height: 180,
    decoration: BoxDecoration(
    borderRadius: const BorderRadius.vertical(
    top: Radius.circular(16),
    ),
    ),
    child: ClipRRect(
    borderRadius: const BorderRadius.vertical(
    top: Radius.circular(16),
    ),
    child: producto['imagen_principal'] != null
    ? Image.network(
    producto['imagen_principal'],
    width: double.infinity,
    height: 180,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Container(
    color: accentColor.withOpacity(0.3),
    child: Center(
    child: CircularProgressIndicator(
    value: loadingProgress.expectedTotalBytes != null
    ? loadingProgress.cumulativeBytesLoaded /
    loadingProgress.expectedTotalBytes!
        : null,
    color: primaryColor,
    ),
    ),
    );
    },
    errorBuilder: (context, error, stackTrace) {
    return Container(
    color: accentColor.withOpacity(0.3),
    child: Center(
    child: Icon(
    Icons.image_not_supported_rounded,
    size: 40,
    color: primaryColor.withOpacity(0.5),
    ),
    ),
    );
    },
    )
        : Container(
    color: accentColor.withOpacity(0.3),
    child: Center(
    child: Icon(
    Icons.image_rounded,
    size: 40,
    color: primaryColor.withOpacity(0.5),
    ),
    ),
    ),
    ),
    ),
    if (producto['es_promocion'] == 1)
    Positioned(
    top: 12,
    right: 12,
    child: Container(
    padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
    ),
    decoration: BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
    'Promoción',
    style: TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    ),
    ],
    ),
    Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    producto['nombre'] ?? 'Sin nombre',
    style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primaryColor,
    height: 1.2,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    ),
      const SizedBox(height: 8),
      Text(
        producto['descripcion'] ?? 'Sin descripción',
        style: TextStyle(
          fontSize: 14,
          color: secondaryColor.withOpacity(0.8),
          height: 1.3,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${formatPrice(producto['precio'])}',
                style: priceStyle,
              ),
              Text(
                'Material: ${producto['tipo_material'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_cart_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${producto['nombre']} agregado al carrito',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ],
    ),
    ),
    ],
    ),
    ),
    );
    },
    ),
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Carrito de compras próximamente'),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.shopping_cart_checkout),
      ),
    );
  }
}