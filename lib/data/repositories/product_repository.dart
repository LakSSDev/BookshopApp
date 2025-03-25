import 'package:bookshop_app/data/database.dart';
import 'package:bookshop_app/data/models/product.dart';

class ProductRepository {
  final DatabaseService _databaseService = DatabaseService();

  
  Future<Product?> getProductById(int id) async {
  final db = await _databaseService.database;
  final result = await db.query(
    'products',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (result.isNotEmpty) {
    return Product.fromMap(result.first);
  }

  return null;
}

  Future<int> insertProduct(Product product) async {
    final db = await _databaseService.database;

    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<void> deleteProduct(int id) async {
    final db = await _databaseService.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateProduct(Product product) async {
    final db = await _databaseService.database;
    await db.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }
}
