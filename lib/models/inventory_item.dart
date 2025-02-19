// lib/models/inventory_item.dart

/// Representa un ítem de inventario (un producto).
/// quantity es mutable para que puedas modificarla al hacer transferencias.
class InventoryItem {
  final String id;
  final String description;
  final String? guiaDespacho;    // Opcional, si se vincula a una guía
  int quantity;                  // int mutable
  final String receiver;         // Quién recibe
  DateTime receptionDateTime;    // Fecha/hora de recepción
  String location;               // Ubicación actual
  String category;               // Categoría

  InventoryItem({
    required this.id,
    required this.description,
    this.guiaDespacho,
    required this.quantity,
    required this.receiver,
    required this.receptionDateTime,
    required this.location,
    required this.category,
  });
}
