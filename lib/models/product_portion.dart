class ProductPortion {
  const ProductPortion({required this.label, required this.price});

  final String label;
  final double price;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'label': label,
      'price': price,
    };
  }

  factory ProductPortion.fromMap(Map<String, dynamic> map) {
    return ProductPortion(
      label: map['label'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
