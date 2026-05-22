import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'mock_data_service.dart';

class FirestoreUploader {
  static Future<void> uploadMockData() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;

    debugPrint('Iniciando upload de categorias...');
    for (int i = 0; i < MockDataService.categories.length; i++) {
      final String category = MockDataService.categories[i];
      await db.collection('categories').doc(category.toLowerCase().replaceAll(' ', '_')).set({
        'name': category,
        'order': i,
      });
    }

    debugPrint('Iniciando upload de produtos...');
    for (final product in MockDataService.products) {
      await db.collection('products').doc(product.id).set(product.toMap());
    }

    debugPrint('Upload concluído com sucesso!');
  }
}
