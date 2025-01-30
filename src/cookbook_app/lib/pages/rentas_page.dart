import 'package:flutter/material.dart';

class RentasPage extends StatelessWidget {
  const RentasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentas'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        itemCount: 10, // Número de elementos en la lista
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.indigo),
              title: Text('Producto ${index + 1}'),
              subtitle: const Text('Disponible para renta'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navegar a la página de detalles del producto
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Seleccionaste el Producto ${index + 1}'),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para agregar un nuevo producto
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Agregar nuevo producto'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}