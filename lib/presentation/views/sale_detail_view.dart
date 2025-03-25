import 'package:flutter/material.dart';
import 'package:bookshop_app/data/models/sale.dart';
import 'package:bookshop_app/data/models/sale_item.dart';
import 'package:bookshop_app/data/models/product.dart';
import 'package:bookshop_app/data/repositories/sale_item_repository.dart';
import 'package:bookshop_app/data/repositories/product_repository.dart';

class SaleDetailView extends StatefulWidget {
  final Sale sale;

  const SaleDetailView({super.key, required this.sale});

  @override
  State<SaleDetailView> createState() => _SaleDetailViewState();
}

class _SaleDetailViewState extends State<SaleDetailView> {
  final SaleItemRepository saleItemRepo = SaleItemRepository();
  final ProductRepository productRepo = ProductRepository();

  List<Map<String, dynamic>> _detailedItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await saleItemRepo.getItemsBySaleId(widget.sale.id!);
    final List<Map<String, dynamic>> detailed = [];

    for (final item in items) {
      final product = await productRepo.getProductById(item.productId);
      if (product != null) {
        detailed.add({
          'name': product.name,
          'quantity': item.quantity,
          'price': item.price,
        });
      }
    }

    setState(() {
      _detailedItems = detailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🗓 Fecha: ${widget.sale.date}'),
            Text('💰 Total: S/. ${widget.sale.total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            const Text('🧾 Productos vendidos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: _detailedItems.isEmpty
                  ? const Text('Cargando productos...')
                  : ListView.builder(
                      itemCount: _detailedItems.length,
                      itemBuilder: (context, index) {
                        final item = _detailedItems[index];
                        final subtotal = item['quantity'] * item['price'];
                        return ListTile(
                          title: Text('${item['name']} x ${item['quantity']}'),
                          subtitle: Text('S/. ${item['price']} c/u'),
                          trailing: Text('S/. ${subtotal.toStringAsFixed(2)}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
