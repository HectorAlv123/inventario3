// lib/models/order.dart
import 'inventory_item.dart';

/// Representa un Pedido (Orden) con una guía de despacho.
class Order {
  final String id;                        // ID único de la orden
  final String guiaDespacho;              // Número de guía
  final String proveedor;                 // Proveedor
  final String ubicacionRecepcion;        // Ubicación de recepción
  final List<InventoryItem> products;     // Lista de ítems agregados al pedido
  final bool isFinalized;                 // Marca si está finalizado
  final String? fotoGuia;                 // Ruta de la imagen de la guía (opcional)

  Order({
    required this.id,
    required this.guiaDespacho,
    required this.proveedor,
    required this.ubicacionRecepcion,
    required this.products,
    this.isFinalized = false,
    this.fotoGuia,
  });
}
