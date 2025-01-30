import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cookbook_joel/pages/design_page.dart';
import 'package:cookbook_joel/pages/forms_page.dart';
import 'package:cookbook_joel/pages/images_page.dart';
import 'package:cookbook_joel/pages/lists_page.dart';
import 'package:cookbook_joel/pages/navigation_page.dart';
import 'package:cookbook_joel/pages/networking/main_networking.dart';
import 'package:cookbook_joel/pages/animations_page.dart';
import 'package:cookbook_joel/pages/persistence_page.dart';
import 'package:cookbook_joel/pages/rentas_page.dart'; // Importa tus páginas
import 'package:cookbook_joel/pages/carrito_page.dart';
import 'package:cookbook_joel/pages/perfil_page.dart';

void main() {
  runApp(const CookbookJoel());
}

class CookbookJoel extends StatelessWidget {
  const CookbookJoel({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rentz',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLoading = true;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(), // Contenido principal de la página de inicio
    const RentasPage(), // Página de rentas
    const CarritoPage(), // Página de carrito
    const PerfilPage(), // Página de perfil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Rentas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  final categories = const [
    {
      'title': 'Diseño IU',
      'icon': 'assets/lottie/design.json',
      'route': DesignPage(),
      'color': Colors.blue,
      'description': '',
    },
    {
      'title': 'Formulario',
      'icon': 'assets/lottie/forms.json',
      'route': FormsPage(),
      'color': Colors.green,
      'description': '',
    },
    {
      'title': 'Imagenes Dinamicas',
      'icon': 'assets/lottie/images.json',
      'route': ImagesPage(),
      'color': Colors.purple,
      'description': '',
    },
    {
      'title': 'Listas',
      'icon': 'assets/lottie/lists.json',
      'route': ListsPage(),
      'color': Colors.orange,
      'description': '',
    },
    {
      'title': 'Navegacion',
      'icon': 'assets/lottie/navigation.json',
      'route': NavigationPage(),
      'color': Colors.red,
      'description': '',
    },
    {
      'title': 'Networking',
      'icon': 'assets/lottie/networking.json',
      'route': MainNetworking(),
      'color': Colors.teal,
      'description': 'Rentadores y Rentadoras',
    },
    {
      'title': 'Animaciones',
      'icon': 'assets/lottie/animations.json',
      'route': AnimationsPage(),
      'color': Colors.pink,
      'description': 'Ejemplos de animaciones en Flutter',
    },
    {
      'title': 'Persistencia',
      'icon': 'assets/lottie/persistence.json',
      'route': PersistencePage(),
      'color': Colors.green,
      'description': 'SQLite, archivos y preferencias',
    },
    {
      'title': 'BetaHome',
      'icon': 'assets/lottie/persistence.json',
      'route': PersistencePage(),
      'color': Colors.green,
      'description': 'SQLite, archivos y preferencias',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          expandedHeight: 200,
          floating: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'CookBook_Joel',
                  textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
              totalRepeatCount: 1,
            ),
            background: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(204), // 0.8 * 255
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds);
              },
              blendMode: BlendMode.darken,
              child: Image.network(
                'https://picsum.photos/800/400',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final category = categories[index];
                return _buildCategoryCard(category, context);
              },
              childCount: categories.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: (category['color'] as Color).withAlpha(102), // 0.4 * 255
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => category['route'] as Widget),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                category['color'] as Color,
                (category['color'] as Color).withAlpha(179), // 0.7 * 255
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  category['icon'] as String,
                  height: 80,
                ),
                const SizedBox(height: 12),
                Text(
                  category['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  category['description'] as String,
                  style: TextStyle(
                    color: Colors.white.withAlpha(204), // 0.8 * 255
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Ejemplo de páginas vacías para rentas, carrito y perfil
class RentasPage extends StatelessWidget {
  const RentasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Página de Rentas'));
  }
}

class CarritoPage extends StatelessWidget {
  const CarritoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Página de Carrito'));
  }
}

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Página de Perfil'));
  }
}