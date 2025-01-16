// lib/pages/design_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class DesignPage extends StatefulWidget {
  const DesignPage({super.key});

  @override
  State<DesignPage> createState() => _DesignPageState();
}

class _DesignPageState extends State<DesignPage> {
  final List<Map<String, dynamic>> sections = [
    {
      'title': 'Material Design 3',
      'description': 'Implementación de los últimos widgets de Material 3',
      'icon': Icons.style,
      'items': [
        {
          'title': 'Botones',
          'widget': _ButtonsShowcase(),
        },
        {
          'title': 'Cards',
          'widget': _CardsShowcase(),
        },
        {
          'title': 'Colores',
          'widget': _ColorSchemeShowcase(),
        },
      ],
    },
    {
      'title': 'Animaciones Personalizadas',
      'description': 'Ejemplos de animaciones implícitas y explícitas',
      'icon': Icons.animation,
      'items': [
        {
          'title': 'Animaciones de Contenedor',
          'widget': _AnimatedContainerShowcase(),
        },
        {
          'title': 'Efectos de Carga',
          'widget': _LoadingEffectsShowcase(),
        },
      ],
    },
    {
      'title': 'Temas Dinámicos',
      'description': 'Cambio de temas y colores en tiempo real',
      'icon': Icons.color_lens,
      'items': [
        {
          'title': 'Theme Switcher',
          'widget': _ThemeSwitcherShowcase(),
        },
      ],
    },
    {
      'title': 'Diseño Responsivo',
      'description': 'Adaptación a diferentes tamaños de pantalla',
      'icon': Icons.devices,
      'items': [
        {
          'title': 'Responsive Layout',
          'widget': _ResponsiveLayoutShowcase(),
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'DISEÑOS IU',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white,),

              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Lottie.asset(
                    'assets/lottie/design.json',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(179),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final section = sections[index];
                  return _buildSection(section);
                },
                childCount: sections.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            section['icon'] as IconData,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          section['title'] as String,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          section['description'] as String,
          style: GoogleFonts.poppins(
            fontSize: 14,
          ),
        ),
        children: [
          for (final item in (section['items'] as List<Map<String, dynamic>>))
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 32),
              title: Text(item['title'] as String),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                _showItemDetails(context, item['title'] as String, item['widget'] as Widget);
              },
            ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, String title, Widget content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: content,
        ),
      ),
    );
  }
}

// Mejora la clase _ButtonsShowcase:
class _ButtonsShowcase extends StatefulWidget {
  @override
  _ButtonsShowcaseState createState() => _ButtonsShowcaseState();
}

class _ButtonsShowcaseState extends State<_ButtonsShowcase> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Elevated Button with loading state
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                setState(() => isLoading = true);
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) setState(() => isLoading = false);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Text('Elevated Button'),
            ),
            const SizedBox(height: 16),
            // Filled Button with icon
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Filled Button'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
            ),
            const SizedBox(height: 16),
            // Outlined Button with animation
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 50),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: const Text('Outlined Button'),
            ),
            const SizedBox(height: 16),
            // Text Button with tooltip
            Tooltip(
              message: 'Text Button Example',
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Text Button'),
              ),
            ),
            const SizedBox(height: 32),
            // Segmented Button
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Opción 1'),
                  icon: Icon(Icons.looks_one),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Opción 2'),
                  icon: Icon(Icons.looks_two),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('Opción 3'),
                  icon: Icon(Icons.looks_3),
                ),
              ],
              selected: {0},
              onSelectionChanged: (Set<int> newSelection) {},
            ),
            const SizedBox(height: 32),
            // FAB showcase
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.small(
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
                FloatingActionButton.large(
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardsShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card básica con sombra
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elevated Card',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text('This is an elevated card example'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('ACCIÓN'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Card con imagen
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Image.network(
                'https://picsum.photos/500/200',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card con Imagen',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text('Ejemplo de card con imagen y acciones'),
                    const SizedBox(height: 8),
                    ButtonBar(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('CANCELAR'),
                        ),
                        FilledButton(
                          onPressed: () {},
                          child: const Text('ACEPTAR'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Card interactiva
        Card(
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Card Interactiva',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Toca para más información',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorSchemeShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        final colors = [
          colorScheme.primary,
          colorScheme.secondary,
          colorScheme.tertiary,
          colorScheme.error,
          colorScheme.primaryContainer,
          colorScheme.secondaryContainer,
          colorScheme.tertiaryContainer,
          colorScheme.errorContainer,
        ];
        final labels = [
          'Primary',
          'Secondary',
          'Tertiary',
          'Error',
          'Primary Container',
          'Secondary Container',
          'Tertiary Container',
          'Error Container',
        ];
        return Container(
          decoration: BoxDecoration(
            color: colors[index],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            labels[index],
            style: TextStyle(
              color: colors[index].computeLuminance() > 0.5 ? Colors.black : Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedContainerShowcase extends StatefulWidget {
  @override
  _AnimatedContainerShowcaseState createState() => _AnimatedContainerShowcaseState();
}

class _AnimatedContainerShowcaseState extends State<_AnimatedContainerShowcase> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isExpanded ? 200 : 100,
          height: _isExpanded ? 200 : 100,
          decoration: BoxDecoration(
            color: _isExpanded
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(_isExpanded ? 32 : 16),
          ),
          child: Center(
            child: Icon(
              _isExpanded ? Icons.remove : Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingEffectsShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 32),
          const LinearProgressIndicator(),
          const SizedBox(height: 32),
          CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSwitcherShowcase extends StatefulWidget {
  @override
  _ThemeSwitcherShowcaseState createState() => _ThemeSwitcherShowcaseState();
}

class _ThemeSwitcherShowcaseState extends State<_ThemeSwitcherShowcase> {
  bool isDark = false;
  Color selectedColor = Colors.blue;
  final List<Color> colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme Mode Switch
              SwitchListTile(
                title: Text(
                  'Modo Oscuro',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Cambiar entre tema claro y oscuro',
                  style: GoogleFonts.poppins(),
                ),
                value: isDark,
                onChanged: (value) {
                  setState(() {
                    isDark = value;
                  });
                  // Aquí implementarías el cambio real del tema
                },
              ),
              const Divider(),
              // Color Picker
              Text(
                'Color del Tema',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colorOptions.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == color
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          if (selectedColor == color)
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: selectedColor == color
                          ? const Icon(
                        Icons.check,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Vista Previa',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedColor,
                      ),
                      onPressed: () {},
                      child: const Text('Botón de Prueba'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponsiveLayoutShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _wideLayout();
        } else {
          return _narrowLayout();
        }
      },
    );
  }

  Widget _wideLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildContent(),
        ),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _narrowLayout() {
    return _buildContent();
  }

  Widget _buildContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text('Item ${index + 1}'),
            subtitle: Text('Description for item ${index + 1}'),
          ),
        );
      },
    );
  }
}