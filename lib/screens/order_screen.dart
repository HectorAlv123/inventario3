// lib/screens/order_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/inventory_item.dart';
import '../models/order.dart';
import '../managers/order_manager.dart';
import '../managers/inventory_manager.dart';
import '../managers/category_manager.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController _guiaController = TextEditingController();
  final TextEditingController _proveedorController = TextEditingController();

  // Datos del pedido
  String? guiaDespacho;
  String? proveedor;
  String? ubicacionRecepcion;

  // Lista de productos en este pedido
  List<InventoryItem> orderProducts = [];

  // Foto de la guía (opcional)
  String? fotoGuia;
  final ImagePicker _picker = ImagePicker();

  // Generador de UUIDs
  final Uuid uuid = const Uuid();

  // Lista fija de ubicaciones
  final List<String> _ubicaciones = [
    'Galpón Azul',
    'Galpón Verde',
    'Bodega de EPPs',
  ];

  @override
  void dispose() {
    _guiaController.dispose();
    _proveedorController.dispose();
    super.dispose();
  }

  // Seleccionar imagen (opcional)
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          fotoGuia = pickedFile.path;
        });
      }
    } catch (e) {
      print("Error al seleccionar imagen: $e");
    }
  }

  // Crear Pedido
  void _createOrder() {
    print("Entrando a _createOrder()");
    // Validar campos obligatorios
    if (_guiaController.text.trim().isEmpty ||
        _proveedorController.text.trim().isEmpty ||
        ubicacionRecepcion == null) {
      print("Falta guía o proveedor o ubicación (Pedido no se crea)");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ingresa la guía, el proveedor y la ubicación de recepción."),
        ),
      );
      return;
    }

    // Si está todo OK
    setState(() {
      guiaDespacho = _guiaController.text.trim();
      proveedor = _proveedorController.text.trim();
    });
    print("Pedido creado con éxito -> Guia: $guiaDespacho, Proveedor: $proveedor, Ubicacion: $ubicacionRecepcion");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pedido creado correctamente.")),
    );
  }

  // Agregar productos al pedido
  void _addProduct() {
    print("Entrando a _addProduct()");
    if (guiaDespacho == null || proveedor == null || ubicacionRecepcion == null) {
      print("No se puede agregar producto, no hay pedido creado aún");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero crea el pedido ingresando todos los datos.")),
      );
      return;
    }

    // Diálogo para ingresar producto y cantidad
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    // Categorías disponibles
    final List<String> catOptions = CategoryManager.instance.categories.isNotEmpty
        ? CategoryManager.instance.categories
        : ['Sin categoría'];
    String selectedCategory = catOptions.first;

    // Productos existentes (para sugerir)
    final List<String> existingProducts = InventoryManager.instance.inventoryItems
        .map((item) => item.description)
        .toSet()
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Agregar producto"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Autocomplete
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return existingProducts.where((option) => option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    descriptionController.text = selection;
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: descriptionController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: "Producto"),
                    );
                  },
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: "Cantidad"),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: catOptions.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setStateDialog(() {
                      if (val != null) {
                        selectedCategory = val;
                      }
                    });
                  },
                  decoration: const InputDecoration(labelText: "Categoría"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  final int qty = int.tryParse(quantityController.text.trim()) ?? 0;
                  if (descriptionController.text.trim().isEmpty || qty <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Datos inválidos")),
                    );
                    return;
                  }

                  // Crear producto
                  final newItem = InventoryItem(
                    id: uuid.v4(),
                    description: descriptionController.text.trim(),
                    guiaDespacho: guiaDespacho,
                    quantity: qty,
                    receiver: "Pedido",
                    receptionDateTime: DateTime.now(),
                    location: ubicacionRecepcion!,
                    category: selectedCategory,
                  );
                  setState(() {
                    orderProducts.add(newItem);
                  });
                  print("Producto agregado: ${newItem.description}, Cant: ${newItem.quantity}");
                  Navigator.of(context).pop();
                },
                child: const Text("Agregar"),
              ),
            ],
          );
        },
      ),
    );
  }

  // Finalizar Pedido
  void _finalizeOrder() async {
    print("Entrando a _finalizeOrder()");
    if (guiaDespacho == null ||
        proveedor == null ||
        ubicacionRecepcion == null ||
        orderProducts.isEmpty) {
      print("No se puede finalizar, faltan datos o no hay productos");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa el pedido antes de finalizarlo.")),
      );
      return;
    }

    // Confirmar acción
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar"),
        content: const Text("¿Estás seguro de que deseas finalizar este pedido?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Finalizar"),
          ),
        ],
      ),
    );

    if (confirm != true) {
      print("Finalización cancelada");
      return;
    }

    // Construir la orden
    final newOrder = Order(
      id: uuid.v4(),
      guiaDespacho: guiaDespacho!,
      proveedor: proveedor!,
      ubicacionRecepcion: ubicacionRecepcion!,
      products: List.from(orderProducts),
      isFinalized: true,
      fotoGuia: fotoGuia, // Si subiste foto
    );

    // Guardar la orden en OrderManager
    print("Guardando orden en OrderManager");
    OrderManager.instance.addOrder(newOrder);

    // Agregar productos al inventario
    print("Agregando productos al InventoryManager");
    for (final prod in orderProducts) {
      InventoryManager.instance.inventoryItems.add(
        InventoryItem(
          id: uuid.v4(),
          description: prod.description,
          guiaDespacho: prod.guiaDespacho,
          quantity: prod.quantity,
          receiver: prod.receiver,
          receptionDateTime: prod.receptionDateTime,
          location: ubicacionRecepcion!,
          category: prod.category,
        ),
      );
    }

    // Mostrar mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pedido finalizado. Se agregaron ${orderProducts.length} productos al inventario.")),
    );

    // Limpiar el estado para un nuevo pedido
    setState(() {
      guiaDespacho = null;
      proveedor = null;
      ubicacionRecepcion = null;
      orderProducts.clear();
      _guiaController.clear();
      _proveedorController.clear();
      fotoGuia = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si no se ha creado pedido, mostramos formulario para crear
    final bool pedidoCreado =
        guiaDespacho != null && proveedor != null && ubicacionRecepcion != null;

    return Scaffold(
      appBar: AppBar(title: const Text("Pedidos con Guía")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pedidoCreado
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Datos del pedido
            Card(
              color: Colors.blue.shade100,
              child: ListTile(
                title: const Text(
                  "Pedido creado",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Guía: $guiaDespacho\nProveedor: $proveedor\nUbicación: $ubicacionRecepcion"),
              ),
            ),
            const SizedBox(height: 10),
            // Si hay foto, la muestra
            if (fotoGuia != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Foto adjunta:"),
                  Image.file(File(fotoGuia!), height: 150),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _addProduct,
                  child: const Text("Agregar productos"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _finalizeOrder,
                  child: const Text("Finalizar Pedido"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Lista de productos agregados
            Expanded(
              child: ListView.builder(
                itemCount: orderProducts.length,
                itemBuilder: (context, index) {
                  final prod = orderProducts[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(prod.description),
                      subtitle: Text("Cantidad: ${prod.quantity}\nCategoría: ${prod.category}"),
                    ),
                  );
                },
              ),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _guiaController,
              decoration: const InputDecoration(labelText: "Número de Guía de Despacho"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _proveedorController,
              decoration: const InputDecoration(labelText: "Proveedor"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: ubicacionRecepcion,
              hint: const Text("Selecciona ubicación de recepción"),
              items: _ubicaciones.map((loc) {
                return DropdownMenuItem(
                  value: loc,
                  child: Text(loc),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  ubicacionRecepcion = val;
                });
              },
              decoration: const InputDecoration(labelText: "Ubicación de Recepción"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createOrder,
              child: const Text("Crear Pedido"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Adjuntar Foto (Opcional)"),
            ),
            if (fotoGuia != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.file(File(fotoGuia!), height: 150),
              ),
          ],
        ),
      ),
    );
  }
}
