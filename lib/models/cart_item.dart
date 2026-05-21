import 'product.dart';
import 'product_portion.dart';

class CartItem {
  CartItem({
    required this.product,
    this.selectedPortion,
    this.observation,
    this.quantity = 1,
  });

  final Product product;
  final ProductPortion? selectedPortion;
  final String? observation;
  int quantity;

  /// Chave única no mapa do carrinho.
  /// Para produtos com porção: "id__label". Sem porção: apenas "id".
  /// Se houver observação, adiciona "__obs" no final.
  String get cartKey {
    String key = product.id;
    if (selectedPortion != null) {
      key += '__${selectedPortion!.label}';
    }
    if (observation != null) {
      // Usando o hash da observação para evitar chaves gigantes e caracteres inválidos
      key += '__obs_${observation.hashCode}';
    }
    return key;
  }

  /// Preço unitário: usa a porção selecionada ou o preço base.
  double get unitPrice => selectedPortion?.price ?? product.price;

  double get subtotal => unitPrice * quantity;
}
