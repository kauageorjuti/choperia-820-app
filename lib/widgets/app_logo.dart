import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 120,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF0D0D0D), Color.fromARGB(115, 8, 136, 21)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logoo.png',
          fit: BoxFit.contain,
          alignment: Alignment.center,
          cacheWidth: (size * 2).toInt(),
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) => const Icon(
            Icons.sports_bar,
            size: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}




