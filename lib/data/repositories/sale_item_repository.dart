import 'package:bookshop_app/data/models/sale_item.dart';
import 'package:bookshop_app/data/database.dart';

class SaleItemRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<void> insertSaleItem(SaleItem item) async {
    final db = await _dbService.database;
    await db.insert('sale_items', item.toMap());
  }

  Future<List<SaleItem>> getItemsBySaleId(int saleId) async {
    final db = await _dbService.database;
    final maps = await db.query('sale_items', where: 'sale_id = ?', whereArgs: [saleId]);
    return maps.map((map) => SaleItem.fromMap(map)).toList();
  }
}
