import 'package:bookshop_app/data/models/sale.dart';
import 'package:bookshop_app/data/database.dart'; // <-- tu nuevo archivo


class SalesRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<int> insertSale(Sale sale) async {
  final db = await _dbService.database;
  return await db.insert('sales', sale.toMap());
}


 Future<List<Sale>> getAllSales() async {
  final db = await _dbService.database;
  final result = await db.query('sales', orderBy: 'date DESC');
  return result.map((map) => Sale.fromMap(map)).toList(); // ✅ usar "result"
}

}
