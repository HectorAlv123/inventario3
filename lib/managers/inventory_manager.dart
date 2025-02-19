// lib/managers/inventory_manager.dart
import '../models/inventory_item.dart';

/// Singleton para manejar la lista de productos en inventario y el historial de transferencias.
class InventoryManager {
  InventoryManager._privateConstructor();
  static final InventoryManager instance = InventoryManager._privateConstructor();

  // Lista principal de ítems en el inventario
  List<InventoryItem> inventoryItems = [];

  // Lista opcional para registrar movimientos de transferencia
  List<dynamic> transferRecords = [];
}
