import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/product_portion.dart';
import '../providers/cart_provider.dart';
import '../utils/formatters.dart';
import '../widgets/app_product_image.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;
  ProductPortion? _selectedPortion;
  final TextEditingController _obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pré-seleciona a primeira porção se o produto tiver porções
    if (widget.product.hasPortions) {
      _selectedPortion = widget.product.portions!.first;
    }
  }

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  void _addToCart() {
    final CartProvider cart = context.read<CartProvider>();
    final String? obs =
        _obsController.text.trim().isEmpty ? null : _obsController.text.trim();
    for (int i = 0; i < _quantity; i++) {
      cart.addProduct(widget.product, portion: _selectedPortion, observation: obs);
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
        content: Text(
          '$_quantity× ${widget.product.name}${_selectedPortion != null ? ' (${_selectedPortion!.label})' : ''} adicionado ao carrinho!',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  /// Preço unitário considerando a porção selecionada
  double get _unitPrice => _selectedPortion?.price ?? widget.product.price;

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              // ── Imagem do produto ────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'product-${product.id}',
                    child: AppProductImage(
                      source: product.image,
                      fit: BoxFit.cover,
                      cacheWidth: 1200,
                    ),
                  ),
                ),
              ),

              // ── Conteúdo ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Nome
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Descrição
                      Text(
                        product.description,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Preço ou Seletor de Porção
                      if (product.hasPortions) ...<Widget>[
                        Text(
                          'Tamanho da porção',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...product.portions!.map((ProductPortion por) {
                          final bool isSelected = _selectedPortion?.label == por.label;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedPortion = por),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cs.primaryContainer
                                    : cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? cs.primary : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    size: 20,
                                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      por.label,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    Formatters.currency(por.price),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? cs.primary : cs.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                      ] else ...<Widget>[
                        Text(
                          Formatters.currency(product.price),
                          style: TextStyle(
                            color: isDark ? Colors.white : cs.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Ingredientes ──────────────────────────
                      if (product.ingredients.isNotEmpty) ...<Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.restaurant_menu_rounded,
                                size: 17, color: cs.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Ingredientes',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: product.ingredients
                                  .map(
                                    (String ingredient) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.check_circle_rounded,
                                            size: 18,
                                            color: cs.primary,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              ingredient,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Observação ────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            'Alguma observação?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${_obsController.text.length}/500',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _obsController,
                        maxLength: 500,
                        maxLines: 3,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText:
                              'Ex: sem cebola, molho à parte...',
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Botão fechar (X) circular — canto superior direito ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // ── Barra inferior: quantidade + botão Adicionar ──────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              child: Row(
                children: <Widget>[
                  // ─ Seletor de quantidade ─────────────────────
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _QtyButton(
                          icon: Icons.remove,
                          onTap: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _QtyButton(
                          icon: Icons.add,
                          onTap: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ─ Botão Adicionar (preto, estilo Tako) ──────
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(
                          'Adicionar  ${Formatters.currency(_unitPrice * _quantity)}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botão de quantidade (+ / -) ───────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 44,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: onTap == null
              ? Theme.of(context).colorScheme.outline
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
