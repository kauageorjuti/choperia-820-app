import 'cart_item.dart';

enum OrderType { delivery, pickup }

enum OrderStatus {
  created,
  accepted,
  preparing,
  onTheWay,
  readyForPickup,
  delivered,
}

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.created:
        return 'Pedido recebido';
      case OrderStatus.accepted:
        return 'Pedido confirmado';
      case OrderStatus.preparing:
        return 'Em preparo';
      case OrderStatus.onTheWay:
        return 'Saiu para entrega';
      case OrderStatus.readyForPickup:
        return 'Pronto para retirada';
      case OrderStatus.delivered:
        return 'Finalizado';
    }
  }
}

class OrderModel {
  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.type,
    required this.createdAt,
    required this.statusHistory,
    this.address,
  });

  final String id;
  final List<CartItem> items;
  final double total;
  final OrderType type;
  final String? address;
  final DateTime createdAt;
  final List<OrderStatus> statusHistory;

  OrderStatus get currentStatus => statusHistory.last;
}
