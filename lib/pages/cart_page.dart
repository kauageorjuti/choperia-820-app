import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../utils/app_routes.dart';
import '../utils/app_texts.dart';
import '../utils/formatters.dart';
import '../widgets/app_product_image.dart';
import '../widgets/empty_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _confirmClearCart(
      BuildContext context, CartProvider cart) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar sacola'),
        content:
            const Text('Deseja remover todos os itens da sacola?'),
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
      ),
    );
    if (confirm != true) return;
    cart.clear();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sacola limpa.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Sua sacola'),
        actions: <Widget>[
          Consumer<CartProvider>(
            builder: (_, CartProvider cart, _) => cart.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () => _confirmClearCart(context, cart),
                    child: Text(
                      'LIMPAR',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (_, CartProvider cart, _) {
          // ── Carrinho vazio ────────────────────────────────
          if (cart.isEmpty) {
            return EmptyState(
              title: context.t('emptyCartTitle'),
              subtitle: context.t('emptyCartSubtitle'),
              icon: Icons.shopping_bag_outlined,
            );
          }

          return Column(
            children: <Widget>[
              // ── Lista de itens ────────────────────────────
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length + 1, // +1 para o footer da lista
                  itemBuilder: (_, int index) {
                    // Footer: "Adicionar mais itens"
                    if (index == cart.items.length) {
                      return _AddMoreButton(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.home),
                      );
                    }

                    final item = cart.items[index];
                    return _CartItemRow(
                      item: item,
                      onRemove: () => cart.removeProduct(item.product.id),
                      onIncrement: () =>
                          cart.incrementQuantity(item.product.id),
                      onDecrement: () =>
                          cart.decrementQuantity(item.product.id),
                    );
                  },
                ),
              ),

              // ── Resumo + botão ────────────────────────────
              _CartSummary(cart: cart),
            ],
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _CartItemRow — item individual no estilo Tako
// ────────────────────────────────────────────────────────────────────────────

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.item,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  final dynamic item;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── Conteúdo esquerdo ────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Qtd × Nome + Preço na mesma linha
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.product.name}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Formatters.currency(item.subtotal),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Editar | Remover + seletor de quantidade
                    Row(
                      children: <Widget>[
                        // "Editar" — abre detalhes do produto
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.productDetails,
                            arguments: item.product,
                          ),
                          child: Text(
                            'Editar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // "Remover"
                        GestureDetector(
                          onTap: onRemove,
                          child: Text(
                            'Remover',
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Seletor − N +
                        _QuantitySelector(
                          quantity: item.quantity,
                          onDecrement: onDecrement,
                          onIncrement: onIncrement,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ── Imagem direita ───────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppProductImage(
                  source: item.product.image,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  cacheWidth: 200,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _QuantitySelector — seletor − N + compacto
// ────────────────────────────────────────────────────────────────────────────

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _QBtn(icon: Icons.remove, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: Text(
                '$quantity',
                key: ValueKey<int>(quantity),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          _QBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _QBtn extends StatelessWidget {
  const _QBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(icon, size: 16),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _AddMoreButton — "Adicionar mais itens" centralizado
// ────────────────────────────────────────────────────────────────────────────

class _AddMoreButton extends StatelessWidget {
  const _AddMoreButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'Adicionar mais itens',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _CartSummary — resumo + botão continuar (estilo Tako)
// ────────────────────────────────────────────────────────────────────────────

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});
  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
              color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Subtotal
          _SummaryRow(
            label: 'Subtotal',
            value: Formatters.currency(cart.totalPrice),
            labelStyle: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            valueStyle: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          // Taxa de entrega
          _SummaryRow(
            label: 'Taxa de entrega',
            value: 'A calcular',
            labelStyle: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            valueStyle: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          const Divider(height: 16),
          // Total
          _SummaryRow(
            label: 'Total',
            value: Formatters.currency(cart.totalPrice),
            labelStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700),
            valueStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          // Botão Continuar pedido — preto como Tako
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.checkout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Continuar pedido'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: labelStyle)),
        Text(value, style: valueStyle),
      ],
    );
  }
}
