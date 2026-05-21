import 'product_portion.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.ingredients,
    this.portions,
  });

  final String id;
  final String name;
  final String description;
  /// Preço base (1 pessoa ou único preço se não tiver porções).
  final double price;
  final String image;
  final String category;
  final List<String> ingredients;
  /// Porções com preços diferentes (ex: 1 pessoa / 2 pessoas).
  /// Null quando o produto tem apenas um preço.
  final List<ProductPortion>? portions;

  bool get hasPortions => portions != null && portions!.isNotEmpty;
}
