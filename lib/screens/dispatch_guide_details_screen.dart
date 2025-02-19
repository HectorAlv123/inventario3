// lib/screens/dispatch_guide_details_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/inventory_item.dart';

class DispatchGuideDetailsScreen extends StatelessWidget {
  final Order order;

  const DispatchGuideDetailsScreen({Key? key, required this.order})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle de Guía: ${order.guiaDespacho}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Información principal de la guía
            Card(
              color: Colors.blue.shade100,
              child: ListTile(
                title: Text("Proveedor: ${order.proveedor}"),
                subtitle: Text("Ubicación: ${order.ubicacionRecepcion}"),
              ),
            ),
            const SizedBox(height: 10),
            // Muestra la foto adjunta, si existe
            if (order.fotoGuia != null)
              Column(
                children: [
                  const Text("Foto adjunta:"),
                  const SizedBox(height: 8),
                  Image.file(
                    File(order.fotoGuia!),
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text("Error al cargar la imagen.");
                    },
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const Text(
              "Productos del pedido",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            // Lista de productos incluidos en la guía
            Expanded(
              child: order.products.isEmpty
                  ? const Center(child: Text("No hay productos en este pedido."))
                  : ListView.builder(
                itemCount: order.products.length,
                itemBuilder: (context, index) {
                  final item = order.products[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(item.description),
                      subtitle: Text(
                          "Cantidad: ${item.quantity}\nCategoría: ${item.category}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
