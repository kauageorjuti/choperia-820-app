import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../utils/app_routes.dart';
import '../utils/app_texts.dart';
import '../utils/formatters.dart';
import '../widgets/app_product_image.dart';
import '../widgets/empty_state.dart';
import '../widgets/tap_scale.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _confirmClearCart(BuildContext context, CartProvider cart) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Limpar carrinho'),
          content: const Text('Deseja remover todos os itens do carrinho?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Limpar'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    cart.clear();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carrinho limpo.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('cart')),
      ),
      body: Consumer<CartProvider>(
        builder: (_, CartProvider cart, _) {
          if (cart.isEmpty) {
            return EmptyState(
              title: context.t('emptyCartTitle'),
              subtitle: context.t('emptyCartSubtitle'),
              icon: Icons.shopping_cart_outlined,
            );
          }

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Adicionar mais itens'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => _confirmClearCart(context, cart),
                      child: const Text('Limpar carrinho'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, int index) {
                    final item = cart.items[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AppProductImage(
                                source: item.product.image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                cacheWidth: 300,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Unitario: ${Formatters.currency(item.product.price)}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    Formatters.currency(item.subtotal),
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                TapScale(
                                  onTap: () => cart.removeProduct(item.product.id),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: 98,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: TapScale(
                                          onTap: () => cart.decrementQuantity(item.product.id),
                                          child: const Center(
                                            child: Icon(Icons.remove, size: 18),
                                          ),
                                        ),
                                      ),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 180),
                                        child: Text(
                                          '${item.quantity}',
                                          key: ValueKey<int>(item.quantity),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: TapScale(
                                          onTap: () => cart.incrementQuantity(item.product.id),
                                          child: const Center(
                                            child: Icon(Icons.add, size: 18),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            context.t('orderTotal'),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                        Text(
                          Formatters.currency(cart.totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.checkout),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                      ),
                      icon: const Icon(Icons.payment_rounded),
                      label: Text(context.t('checkout')),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
