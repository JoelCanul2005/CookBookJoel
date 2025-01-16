import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  final List<Map<String, dynamic>> _items = List.generate(
    20,
        (index) => {
      'id': index,
      'title': 'Item ${index + 1}',
      'subtitle': 'Descripción del item ${index + 1}',
      'isSelected': false,
      'color': Colors.primaries[Random().nextInt(Colors.primaries.length)],
    },
  );

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
                'Listas',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white,),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Lottie.asset(
                    'assets/lottie/lists.json',
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final item = _items[index];
                return _buildListItem(item, index);
              },
              childCount: _items.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        label: Row(
          children: const [
            Icon(Icons.add),
            SizedBox(width: 5),
            Text("Nuevo Item"),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item, int index) {
    return Dismissible(
      key: ValueKey(item['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _removeItem(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
          horizontal: item['isSelected'] ? 16 : 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: item['isSelected']
              ? item['color'].withOpacity(0.5)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: item['color'],
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            item['title'],
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            item['subtitle'],
            style: GoogleFonts.poppins(),
          ),
          trailing: IconButton(
            icon: Icon(
              item['isSelected'] ? Icons.check_circle : Icons.circle_outlined,
              color: item['isSelected']
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: () => _toggleSelection(index),
          ),
          onTap: () => _toggleSelection(index),
        ),
      ),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      _items[index]['isSelected'] = !_items[index]['isSelected'];
    });
  }

  void _addItem() {
    setState(() {
      _items.insert(0, {
        'id': _items.length,
        'title': 'Nuevo Item',
        'subtitle': 'Descripción del nuevo item',
        'isSelected': false,
        'color': Colors.primaries[Random().nextInt(Colors.primaries.length)],
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }
}
