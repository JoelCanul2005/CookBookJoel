// producto_form.dart
import 'package:flutter/material.dart';

class ProductoForm extends StatefulWidget {
  final Map<String, dynamic>? producto;
  final Function(Map<String, dynamic>) onSubmit;

  const ProductoForm({
    Key? key,
    this.producto,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ProductoForm> createState() => _ProductoFormState();
}

class _ProductoFormState extends State<ProductoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _materialController = TextEditingController();
  final _imagenController = TextEditingController();
  bool _esPromocion = false;

  @override
  void initState() {
    super.initState();
    if (widget.producto != null) {
      _nombreController.text = widget.producto!['nombre'] ?? '';
      _descripcionController.text = widget.producto!['descripcion'] ?? '';
      _precioController.text = widget.producto!['precio']?.toString() ?? '';
      _cantidadController.text = widget.producto!['cantidad_disponible']?.toString() ?? '';
      _materialController.text = widget.producto!['tipo_material'] ?? '';
      _imagenController.text = widget.producto!['imagen_principal'] ?? '';
      _esPromocion = widget.producto!['es_promocion'] == 1 ? true : false;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    _materialController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(labelText: 'Nombre'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese un nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _descripcionController,
            decoration: const InputDecoration(labelText: 'Descripción'),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese una descripción';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _precioController,
            decoration: const InputDecoration(labelText: 'Precio'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese un precio';
              }
              if (double.tryParse(value) == null) {
                return 'Por favor ingrese un precio válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _cantidadController,
            decoration: const InputDecoration(labelText: 'Cantidad disponible'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese una cantidad';
              }
              if (int.tryParse(value) == null) {
                return 'Por favor ingrese un número válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _materialController,
            decoration: const InputDecoration(labelText: 'Tipo de material'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el tipo de material';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _imagenController,
            decoration: const InputDecoration(labelText: 'URL de la imagen'),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Es promoción'),
            value: _esPromocion,
            onChanged: (bool value) {
              setState(() {
                _esPromocion = value;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final productoData = {
                  'nombre': _nombreController.text,
                  'descripcion': _descripcionController.text,
                  'precio': double.parse(_precioController.text),
                  'cantidad_disponible': int.parse(_cantidadController.text),
                  'tipo_material': _materialController.text,
                  'es_promocion': _esPromocion ? 1 : 0,
                  'imagen_principal': _imagenController.text.isEmpty
                      ? 'https://via.placeholder.com/150'
                      : _imagenController.text,
                };
                widget.onSubmit(productoData);
              }
            },
            child: Text(widget.producto == null ? 'Agregar' : 'Actualizar'),
          ),
        ],
      ),
    );
  }
}