import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/firestore_service.dart';

class MenuProvider extends ChangeNotifier {
  MenuProvider({FirestoreService? service}) : _service = service ?? FirestoreService();

  final FirestoreService _service;
  final List<Product> _products = <Product>[];
  final List<String> _categories = <String>['Tudo']; // "Tudo" é sempre a primeira

  bool _isLoading = false;
  String _selectedCategory = 'Tudo';
  String _searchQuery = '';

  List<Product> get products => List<Product>.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<String> get categories => List<String>.unmodifiable(_categories);

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

    // Buscar categorias e produtos paralelamente
    final results = await Future.wait([
      _service.getCategories(),
      _service.getProducts(),
    ]);

    final List<String> loadedCategories = results[0] as List<String>;
    final List<Product> loadedProducts = results[1] as List<Product>;

    _categories
      ..clear()
      ..add('Tudo')
      ..addAll(loadedCategories.where((String c) => c.toLowerCase() != 'tudo'));

    _products
      ..clear()
      ..addAll(loadedProducts);

    // Ordenar os produtos para que sigam a ordem das categorias
    // Em vez de ordem alfabética da ID do Firebase (que colocava 'Adicionais' primeiro)
    final Map<String, int> categoryOrderMap = <String, int>{};
    for (int i = 0; i < _categories.length; i++) {
      categoryOrderMap[_categories[i]] = i;
    }

    _products.sort((Product a, Product b) {
      final int orderA = categoryOrderMap[a.category] ?? 999;
      final int orderB = categoryOrderMap[b.category] ?? 999;
      if (orderA == orderB) {
        return a.name.compareTo(b.name);
      }
      return orderA.compareTo(orderB);
    });

    // Se a categoria selecionada não existir mais (raro), volta pra Tudo
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'Tudo';
    }

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
