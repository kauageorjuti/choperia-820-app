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
    required this.userId,
    required this.items,
    required this.total,
    required this.type,
    required this.createdAt,
    required this.statusHistory,
    required this.userName,
    this.userPhone,
    this.address,
    this.observation,
  });

  final String id;
  final String userId;
  final String userName;
  final String? userPhone;
  final List<CartItem> items;
  final double total;
  final OrderType type;
  final String? address;
  final String? observation;
  final DateTime createdAt;
  final List<OrderStatus> statusHistory;

  OrderStatus get currentStatus => statusHistory.last;

  /// Returns a short pretty ID like "#2591"
  String get shortCode {
    final String numbersOnly = id.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbersOnly.isEmpty) return '#0000';
    final String shortId =
        numbersOnly.length > 4 ? numbersOnly.substring(numbersOnly.length - 4) : numbersOnly;
    return '#$shortId';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'type': type.name,
      'address': address,
      'observation': observation,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'statusHistory': statusHistory.map((s) => s.name).toList(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return OrderModel(
      id: documentId ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'Cliente',
      userPhone: map['userPhone'] as String?,
      items: (map['items'] as List<dynamic>?)
              ?.map((i) => CartItem.fromMap(Map<String, dynamic>.from(i as Map)))
              .toList() ??
          [],
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      type: OrderType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => OrderType.delivery,
      ),
      address: map['address'] as String?,
      observation: map['observation'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int? ?? 0),
      statusHistory: (map['statusHistory'] as List<dynamic>?)
              ?.map((s) => OrderStatus.values.firstWhere(
                    (e) => e.name == s,
                    orElse: () => OrderStatus.created,
                  ))
              .toList() ??
          [OrderStatus.created],
    );
  }
}
