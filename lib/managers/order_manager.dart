// lib/managers/order_manager.dart
import '../models/order.dart';

/// Singleton para manejar la lista de pedidos (órdenes) y un pedido pendiente.
class OrderManager {
  OrderManager._privateConstructor();
  static final OrderManager instance = OrderManager._privateConstructor();

  final List<Order> _orders = [];
  Order? pendingOrder;

  // Getter para acceder a las órdenes
  List<Order> get orders => _orders;

  // Agregar una orden a la lista
  void addOrder(Order order) {
    if (!order.isFinalized) {
      pendingOrder = order;
    }
    _orders.add(order);
  }

  // Eliminar una orden
  void removeOrder(Order order) {
    _orders.remove(order);
    if (pendingOrder == order) {
      pendingOrder = null;
    }
  }
}
