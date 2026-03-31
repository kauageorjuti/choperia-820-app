import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/mock_data_service.dart';

class MenuProvider extends ChangeNotifier {
  MenuProvider({MockDataService? service}) : _service = service ?? MockDataService();

  final MockDataService _service;
  final List<Product> _products = <Product>[];
  bool _isLoading = false;
  String _selectedCategory = MockDataService.categories.first;
  String _searchQuery = '';

  List<Product> get products => List<Product>.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<String> get categories => MockDataService.categories;

  List<Product> get filteredProducts {
    if (_selectedCategory == 'Tudo') {
      return products;
    }
    return products.where((Product p) => p.category == _selectedCategory).toList();
  }

  List<Product> get visibleProducts {
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return filteredProducts;
    return filteredProducts.where((Product p) {
      return p.name.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    final List<Product> loaded = await _service.fetchProducts();
    _products
      ..clear()
      ..addAll(loaded);
    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
