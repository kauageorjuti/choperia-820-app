import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retorna as categorias cadastradas (se houver uma coleção separada)
  /// Caso contrário, podemos extraí-las dos produtos. Vamos usar uma coleção 'categories'
  Future<List<String>> getCategories() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _db.collection('categories').orderBy('order').get();
      return snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
    } catch (e) {
      // Se não houver, retorna vazio para ser tratado pelo provedor
      return <String>[];
    }
  }

  /// Retorna todos os produtos
  Future<List<Product>> getProducts() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _db.collection('products').get();
      return snapshot.docs.map((doc) => Product.fromMap(doc.data(), documentId: doc.id)).toList();
    } catch (e) {
      return <Product>[];
    }
  }

  /// Cria um novo pedido
  Future<void> createOrder(OrderModel order) async {
    await _db.collection('orders').doc(order.id).set(order.toMap());
  }

  /// Escuta atualizações de um pedido específico
  Stream<OrderModel?> watchOrder(String orderId) {
    return _db.collection('orders').doc(orderId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return OrderModel.fromMap(doc.data()!, documentId: doc.id);
    });
  }

  /// Retorna os pedidos de um usuário específico (usando número de telefone ou auth uid)
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), documentId: doc.id))
          .toList();
    } catch (e) {
      return <OrderModel>[];
    }
  }
}
