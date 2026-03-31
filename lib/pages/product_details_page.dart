import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
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
  bool _animated = false;

  void _addToCart() {
    context.read<CartProvider>().addProduct(widget.product);
    setState(() => _animated = true);
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _animated = false);
    });
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text('${widget.product.name} adicionado ao carrinho!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 290,
            pinned: true,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Formatters.currency(product.price),
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ingredientes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: product.ingredients
                        .map(
                          (String ingredient) => Chip(
                            label: Text(ingredient),
                            avatar: const Icon(Icons.check_rounded, size: 16),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                  AnimatedScale(
                    scale: _animated ? 1.02 : 1,
                    duration: const Duration(milliseconds: 250),
                    child: FilledButton.icon(
                      onPressed: _addToCart,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: const Text('Adicionar ao carrinho'),
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
