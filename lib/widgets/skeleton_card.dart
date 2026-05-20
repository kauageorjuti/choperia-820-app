import 'package:flutter/material.dart';

/// Skeleton no estilo horizontal (igual ao novo ProductCard).
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final double opacity = 0.15 + (_controller.value * 0.25);
        final Color shade = Colors.grey.withValues(alpha: opacity);
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(height: 14, width: double.infinity, color: shade),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 200, color: shade),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 160, color: shade),
                    const SizedBox(height: 14),
                    Container(height: 13, width: 70, color: shade),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 112,
                height: 80,
                decoration: BoxDecoration(
                  color: shade,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
