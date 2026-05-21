import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  OrderModel? _currentOrder;
  Timer? _statusTimer;

  OrderModel? get currentOrder => _currentOrder;

  Future<OrderModel> placeOrder({
    required List<CartItem> items,
    required double total,
    required OrderType type,
    String? address,
    String? observation,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
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

    _currentOrder = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: snapshotItems,
      total: total,
      type: type,
      address: address,
      observation: observation,
      createdAt: DateTime.now(),
      statusHistory: <OrderStatus>[OrderStatus.created],
    );
    notifyListeners();
    _startProgressSimulation();
    return _currentOrder!;
  }

  void _startProgressSimulation() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      final OrderModel? order = _currentOrder;
      if (order == null) return;

      final List<OrderStatus> flow = order.type == OrderType.delivery
          ? <OrderStatus>[
              OrderStatus.accepted,
              OrderStatus.preparing,
              OrderStatus.onTheWay,
              OrderStatus.delivered,
            ]
          : <OrderStatus>[
              OrderStatus.accepted,
              OrderStatus.preparing,
              OrderStatus.readyForPickup,
              OrderStatus.delivered,
            ];

      if (order.statusHistory.length >= flow.length + 1) {
        timer.cancel();
        return;
      }

      order.statusHistory.add(flow[order.statusHistory.length - 1]);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}
