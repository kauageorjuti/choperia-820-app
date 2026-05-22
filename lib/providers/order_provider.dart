import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({FirestoreService? service}) : _service = service ?? FirestoreService();

  final FirestoreService _service;
  OrderModel? _currentOrder;
  StreamSubscription<OrderModel?>? _orderSubscription;

  OrderModel? get currentOrder => _currentOrder;

  Future<OrderModel> placeOrder({
    required String userId,
    required String userName,
    String? userPhone,
    required List<CartItem> items,
    required double total,
    required OrderType type,
    String? address,
    String? observation,
  }) async {
    final List<CartItem> snapshotItems = items
        .map(
          (CartItem i) => CartItem(
            product: i.product,
            quantity: i.quantity,
            selectedPortion: i.selectedPortion,
            observation: i.observation,
          ),
        )
        .toList();

    final String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    _currentOrder = OrderModel(
      id: orderId,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      items: snapshotItems,
      total: total,
      type: type,
      address: address,
      observation: observation,
      createdAt: DateTime.now(),
      statusHistory: <OrderStatus>[OrderStatus.created],
    );

    await _service.createOrder(_currentOrder!);

    _startListeningToOrder(orderId);
    
    notifyListeners();
    return _currentOrder!;
  }

  void _startListeningToOrder(String orderId) {
    _orderSubscription?.cancel();
    _orderSubscription = _service.watchOrder(orderId).listen((OrderModel? updatedOrder) {
      if (updatedOrder != null) {
        _currentOrder = updatedOrder;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }
}
