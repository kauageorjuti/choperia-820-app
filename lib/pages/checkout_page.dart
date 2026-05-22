import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../utils/app_routes.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/tap_scale.dart';

enum PaymentMethod { credit, debit, pix, cash }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const double _deliveryFee = 7.0;

  OrderType _selectedType = OrderType.delivery;
  PaymentMethod _paymentMethod = PaymentMethod.credit;
  bool _isSubmitting = false;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login ou cadastre-se para finalizar o pedido.')),
      );
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    final CartProvider cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    if (_selectedType == OrderType.delivery && _addressController.text.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um endereço de entrega válido.')),
      );
      return;
    }

    final double subtotal = cart.totalPrice;
    final double finalTotal = subtotal + _deliveryFee;

    setState(() => _isSubmitting = true);
    final OrderModel order = await context.read<OrderProvider>().placeOrder(
          userId: auth.currentUser!.id,
          userName: auth.currentUser!.name,
          userPhone: auth.currentUser!.phone,
          items: cart.items,
          total: finalTotal,
          type: _selectedType,
          address: _selectedType == OrderType.delivery ? _addressController.text.trim() : null,
          observation: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
    cart.clear();

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.orderConfirmation,
      ModalRoute.withName(AppRoutes.home),
      arguments: order.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Consumer<CartProvider>(
        builder: (_, CartProvider cart, _) {
          if (cart.isEmpty) {
            return const EmptyState(
              title: 'Sem itens para finalizar',
              subtitle: 'Adicione itens no carrinho para continuar.',
              icon: Icons.point_of_sale_outlined,
            );
          }

          final double subtotal = cart.totalPrice;
          final double total = subtotal + _deliveryFee;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const _CheckoutSteps(),
              const SizedBox(height: 14),
              _SectionCard(
                icon: Icons.local_shipping_outlined,
                title: 'Tipo de pedido',
                child: SegmentedButton<OrderType>(
                  segments: const <ButtonSegment<OrderType>>[
                    ButtonSegment<OrderType>(
                      value: OrderType.delivery,
                      icon: Icon(Icons.local_shipping_outlined),
                      label: Text('Entrega'),
                    ),
                    ButtonSegment<OrderType>(
                      value: OrderType.pickup,
                      icon: Icon(Icons.storefront_outlined),
                      label: Text('Retirada'),
                    ),
                  ],
                  selected: <OrderType>{_selectedType},
                  onSelectionChanged: (Set<OrderType> selected) {
                    setState(() => _selectedType = selected.first);
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedType == OrderType.delivery)
                _SectionCard(
                  icon: Icons.location_on_outlined,
                  title: 'Endereço de Entrega',
                  child: TextField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Rua, numero, bairro, cidade, estado, CEP',
                    ),
                  ),
                ),
              if (_selectedType == OrderType.delivery) const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.credit_card_rounded,
                title: 'Metodo de Pagamento',
                child: Column(
                  children: <Widget>[
                    _PaymentOptionTile(
                      icon: Icons.credit_card,
                      label: 'Cartão de Crédito',
                      selected: _paymentMethod == PaymentMethod.credit,
                      onTap: () => setState(() => _paymentMethod = PaymentMethod.credit),
                    ),
                    const SizedBox(height: 10),
                    _PaymentOptionTile(
                      icon: Icons.credit_card_outlined,
                      label: 'Cartão de Debito',
                      selected: _paymentMethod == PaymentMethod.debit,
                      onTap: () => setState(() => _paymentMethod = PaymentMethod.debit),
                    ),
                    const SizedBox(height: 10),
                    _PaymentOptionTile(
                      icon: Icons.qr_code_2_rounded,
                      label: 'PIX',
                      selected: _paymentMethod == PaymentMethod.pix,
                      onTap: () => setState(() => _paymentMethod = PaymentMethod.pix),
                    ),
                    const SizedBox(height: 10),
                    _PaymentOptionTile(
                      icon: Icons.payments_outlined,
                      label: 'Dinheiro',
                      selected: _paymentMethod == PaymentMethod.cash,
                      onTap: () => setState(() => _paymentMethod = PaymentMethod.cash),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.note_alt_outlined,
                title: 'Observações (Opcional)',
                child: TextField(
                  controller: _notesController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Ex: sem sal, sem cebola, etc.',
                  ),
                ),
              ),
              _SectionCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Itens do Pedido',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cart.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.product.name}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                Formatters.currency(item.subtotal),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          if (item.selectedPortion != null)
                            Text(
                              item.selectedPortion!.label,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          if (item.observation != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Obs: ${item.observation}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.receipt_long_outlined,
                title: 'Resumo do Pedido',
                child: Column(
                  children: <Widget>[
                    _priceLine('Subtotal', Formatters.currency(subtotal)),
                    _priceLine('Taxa de entrega', Formatters.currency(_deliveryFee)),
                    const Divider(height: 24),
                    _priceLine(
                      'Total',
                      Formatters.currency(total),
                      bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Consumer<AuthProvider>(
                builder: (_, AuthProvider auth, _) {
                  if (auth.isAuthenticated) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Fazendo pedido como: ${auth.currentUser?.name ?? "Cliente"}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _confirmOrder,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(_isSubmitting ? 'Confirmando...' : 'Confirmar Pedido'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _priceLine(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bold ? 16 : 14,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 20 : 14,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
              color: bold
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSteps extends StatelessWidget {
  const _CheckoutSteps();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: _StepItem(index: 1, label: 'Entrega', active: true)),
        Container(height: 1, width: 28, color: Theme.of(context).colorScheme.outlineVariant),
        const Expanded(child: _StepItem(index: 2, label: 'Pagamento', active: true)),
        Container(height: 1, width: 28, color: Theme.of(context).colorScheme.outlineVariant),
        const Expanded(child: _StepItem(index: 3, label: 'Confirmação', active: false)),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.index,
    required this.label,
    required this.active,
  });

  final int index;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: TextStyle(
              color: active ? Theme.of(context).colorScheme.onPrimary : null,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return TapScale(
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? scheme.primary.withValues(alpha: 0.08)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  Icons.check_circle,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
