import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../utils/app_routes.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  List<OrderStatus> _flow(OrderType type) {
    return type == OrderType.delivery
        ? <OrderStatus>[
            OrderStatus.created,
            OrderStatus.accepted,
            OrderStatus.preparing,
            OrderStatus.onTheWay,
            OrderStatus.delivered,
          ]
        : <OrderStatus>[
            OrderStatus.created,
            OrderStatus.accepted,
            OrderStatus.preparing,
            OrderStatus.readyForPickup,
            OrderStatus.delivered,
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acompanhar Pedido')),
      body: Consumer<OrderProvider>(
        builder: (_, OrderProvider orderProvider, _) {
          final OrderModel? order = orderProvider.currentOrder;
          if (order == null) {
            return const EmptyState(
              title: 'Nenhum pedido ativo',
              subtitle: 'Assim que voce finalizar um pedido ele aparece aqui.',
              icon: Icons.receipt_long_outlined,
            );
          }

          final List<OrderStatus> statusFlow = _flow(order.type);
          final int currentIndex = statusFlow.indexOf(order.currentStatus);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 470),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _TrackingCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Pedido ${order.shortCode}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            order.type == OrderType.delivery
                                ? 'Tipo: Entrega'
                                : 'Tipo: Retirada no balcão',
                          ),
                          if (order.address != null) Text('Endereço: ${order.address}'),
                          const SizedBox(height: 6),
                          Text('Total: ${Formatters.currency(order.total)}'),
                          if (order.observation != null) ...<Widget>[
                            const SizedBox(height: 10),
                            Text(
                              'Observação Geral:\n${order.observation}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TrackingCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Itens do pedido',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...order.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('${item.quantity}x ${item.product.name}'),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Status do pedido',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    ...statusFlow.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final OrderStatus status = entry.value;
                      final bool done = index <= currentIndex;
                      final bool isCurrent = index == currentIndex;
                      return _StatusTile(
                        label: status.label,
                        done: done,
                        isCurrent: isCurrent,
                        isLast: index == statusFlow.length - 1,
                      );
                    }),
                    const SizedBox(height: 20),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.home,
                            (Route<dynamic> _) => false,
                          );
                        },
                        icon: const Icon(Icons.restaurant_menu_rounded),
                        label: const Text('Voltar para o cardápio'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.label,
    required this.done,
    required this.isCurrent,
    required this.isLast,
  });

  final String label;
  final bool done;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 64,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 28,
            child: Column(
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? scheme.primary : scheme.surfaceContainerHighest,
                  ),
                  child: Icon(
                    done ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: done ? scheme.onPrimary : scheme.onSurfaceVariant,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: done ? scheme.primary : scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                  color: done ? null : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
