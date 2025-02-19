// lib/screens/dispatch_guides_screen.dart
import 'package:flutter/material.dart';
import '../managers/order_manager.dart';
import '../models/order.dart';
import 'dispatch_guide_details_screen.dart';

class DispatchGuidesScreen extends StatelessWidget {
  const DispatchGuidesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtra solo los pedidos finalizados
    List<Order> finalizedOrders = OrderManager.instance.orders
        .where((order) => order.isFinalized)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Guías de Despacho Finalizadas"),
      ),
      body: finalizedOrders.isEmpty
          ? const Center(child: Text("No hay guías finalizadas."))
          : ListView.builder(
        itemCount: finalizedOrders.length,
        itemBuilder: (context, index) {
          final order = finalizedOrders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              title: Text("Guía: ${order.guiaDespacho}"),
              subtitle: Text(
                  "Proveedor: ${order.proveedor}\nUbicación: ${order.ubicacionRecepcion}"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        DispatchGuideDetailsScreen(order: order),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
