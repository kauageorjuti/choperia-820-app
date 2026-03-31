import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppProductImage extends StatelessWidget {
  const AppProductImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.cacheWidth,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? cacheWidth;

  bool _isNetworkUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final String safeSource = source.trim();
    if (safeSource.isEmpty) {
      return _fallback(context);
    }

    if (_isNetworkUrl(safeSource)) {
      return Image.network(
        safeSource,
        width: width,
        height: height,
        fit: fit,
        filterQuality: kIsWeb ? FilterQuality.none : FilterQuality.low,
        loadingBuilder: (_, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return _fallback(context, loading: true);
        },
        errorBuilder: (_, _, _) => _fallback(context),
      );
    }

    return Image.asset(
      safeSource,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.low,
      errorBuilder: (_, _, _) => _fallback(context),
    );
  }

  Widget _fallback(BuildContext context, {bool loading = false}) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Image.asset(
              'assets/images/cardapio.jpg',
              fit: BoxFit.cover,
              width: width,
              height: height,
              filterQuality: FilterQuality.low,
              errorBuilder: (_, _, _) => const Icon(Icons.fastfood_rounded),
            ),
    );
  }
}
