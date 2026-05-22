import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/app_logo.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key, this.orderId});

  final String? orderId;

  String _prettyOrderId(String? raw) {
    if (raw == null || raw.isEmpty) return '#0000';
    final String numbersOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbersOnly.isEmpty) return '#0000';
    final String shortId =
        numbersOnly.length > 4 ? numbersOnly.substring(numbersOnly.length - 4) : numbersOnly;
    return '#$shortId';
  }

  @override
  Widget build(BuildContext context) {
    final String? providerOrderId = context.watch<OrderProvider>().currentOrder?.id;
    final String code = _prettyOrderId(orderId ?? providerOrderId);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFF0A1F0E),
              Color(0xFF0D1A10),
              Color(0xFF0A120E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.84, end: 1),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    builder: (_, double value, Widget? child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: const AppLogo(size: 84),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Pedido Confirmado!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Seu pedido foi recebido com sucesso\nEm breve ele estará pronto!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Color(0xFFD9D9E3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    code,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 38,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (Route<dynamic> _) => false,
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                    ),
                    child: const Text('Voltar'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.tracking),
                    child: const Text('Acompanhar pedido'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
