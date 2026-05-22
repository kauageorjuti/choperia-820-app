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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'ingredients': ingredients,
      'portions': portions?.map((p) => p.toMap()).toList(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, {String? documentId}) {
    final portionsData = map['portions'] as List<dynamic>?;
    return Product(
      id: documentId ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      image: map['image'] as String? ?? '',
      category: map['category'] as String? ?? '',
      ingredients: (map['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      portions: portionsData?.map((p) => ProductPortion.fromMap(Map<String, dynamic>.from(p))).toList(),
    );
  }
}
