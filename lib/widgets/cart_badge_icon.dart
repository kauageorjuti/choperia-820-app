import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CartBadgeIcon extends StatelessWidget {
  const CartBadgeIcon({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (_, CartProvider cart, _) {
        return IconButton(
          onPressed: onTap,
          tooltip: 'Carrinho',
          icon: Badge(
            isLabelVisible: cart.totalItems > 0,
            label: Text(
              cart.totalItems.toString(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            textColor: Colors.black,
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        );
      },
    );
  }
}
