import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/product_portion.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = <String, CartItem>{};

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;
  int get totalItems =>
      _items.values.fold<int>(0, (int total, CartItem item) => total + item.quantity);
  double get totalPrice => _items.values.fold<double>(
        0,
        (double total, CartItem item) => total + item.subtotal,
      );

  void addProduct(Product product, {ProductPortion? portion, String? observation}) {
    final CartItem temp = CartItem(product: product, selectedPortion: portion);
    final String key = temp.cartKey;
    if (_items.containsKey(key)) {
      _items[key]!.quantity++;
    } else {
      _items[key] = CartItem(
        product: product,
        selectedPortion: portion,
        observation: observation?.trim().isEmpty == true ? null : observation?.trim(),
      );
    }
    notifyListeners();
  }

  void updateProduct(String oldCartKey, CartItem updatedItem) {
    if (oldCartKey != updatedItem.cartKey) {
      _items.remove(oldCartKey);
    }
    _items[updatedItem.cartKey] = updatedItem;
    notifyListeners();
  }

  /// Remove item pelo cartKey (ex: "pr-1__2 Pessoas" ou "pt-1").
  void removeProduct(String cartKey) {
    _items.remove(cartKey);
    notifyListeners();
  }

  void incrementQuantity(String cartKey) {
    final CartItem? item = _items[cartKey];
    if (item == null) return;
    item.quantity++;
    notifyListeners();
  }

  void decrementQuantity(String cartKey) {
    final CartItem? item = _items[cartKey];
    if (item == null) return;
    if (item.quantity <= 1) {
      _items.remove(cartKey);
    } else {
      item.quantity--;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
