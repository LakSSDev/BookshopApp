import 'package:flutter/material.dart';
import 'package:bookshop_app/data/models/product.dart';
import 'package:bookshop_app/data/models/sale.dart';
import 'package:bookshop_app/data/models/sale_item.dart';
import 'package:bookshop_app/data/repositories/product_repository.dart';
import 'package:bookshop_app/data/repositories/sale_item_repository.dart';
import 'package:bookshop_app/data/repositories/sales_repository.dart';

class SalesView extends StatefulWidget {
  const SalesView({super.key});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  final ProductRepository productRepo = ProductRepository();
  final SalesRepository salesRepo = SalesRepository();
  final SaleItemRepository saleItemRepo = SaleItemRepository();

  List<Product> _products = [];
  Product? _selectedProduct;
  final TextEditingController quantityController = TextEditingController();

  List<Map<String, dynamic>> _saleItems = []; // Productos agregados

  double get total => _saleItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await productRepo.getAllProducts();
    setState(() {
      _products = products;
    });
  }

  void _addToSale() {
    final int quantity = int.tryParse(quantityController.text) ?? 0;
    if (_selectedProduct == null || quantity <= 0) return;

    final exists = _saleItems.any((item) => item['product'].id == _selectedProduct!.id);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto ya agregado')),
      );
      return;
    }

    setState(() {
      _saleItems.add({
        'product': _selectedProduct!,
        'quantity': quantity,
        'price': _selectedProduct!.price,
      });
      quantityController.clear();
    });
  }

  void _clearSale() {
    setState(() {
      _saleItems.clear();
    });
  }

  Future<void> _finalizeSale() async {
    // 1. Guardar la venta
    final sale = Sale(
      date: DateTime.now().toIso8601String(),
      total: total,
    );

    final saleId = await salesRepo.insertSale(sale); // ✅ SOLO UNA VEZ

    // 2. Guardar productos vendidos
    for (var item in _saleItems) {
      final product = item['product'] as Product;
      final int quantity = item['quantity'];
      final double price = item['price'];

      final saleItem = SaleItem(
        saleId: saleId,
        productId: product.id!,
        quantity: quantity,
        price: price,
      );

      await saleItemRepo.insertSaleItem(saleItem);
    }

    // 3. Actualizar stock
    for (var item in _saleItems) {
      final Product product = item['product'];
      final int quantity = item['quantity'];

      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        price: product.price,
        stock: product.stock! - quantity,
      );

      await productRepo.updateProduct(updatedProduct);
    }

    // 4. Limpiar
    _clearSale();
    setState(() => _selectedProduct = null);
    await _loadProducts();

    // 5. Confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Venta registrada y stock actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Registrar Venta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Selección de producto
          DropdownButtonFormField<Product>(
            value: _products.contains(_selectedProduct) ? _selectedProduct : null,
            decoration: const InputDecoration(labelText: 'Seleccionar producto'),
            items: _products.map((product) {
              return DropdownMenuItem(
                value: product,
                child: Text('${product.name} - S/. ${product.price?.toStringAsFixed(2) ?? '0.00'}'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedProduct = value),
          ),

          const SizedBox(height: 8),

          // Cantidad
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad'),
          ),

          const SizedBox(height: 8),

          // Botón Agregar
          ElevatedButton.icon(
            onPressed: _addToSale,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Agregar a la venta'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const Text('Productos agregados:', style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 8),

          Expanded(
            child: _saleItems.isEmpty
                ? const Center(child: Text('No hay productos agregados.'))
                : ListView.builder(
                    itemCount: _saleItems.length,
                    itemBuilder: (context, index) {
                      final item = _saleItems[index];
                      final product = item['product'] as Product;
                      final int quantity = item['quantity'];
                      final num subtotal = quantity * item['price'];

                      return ListTile(
                        title: Text('${product.name} x $quantity'),
                        subtitle: Text('Subtotal: S/. ${subtotal.toStringAsFixed(2)}'),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 8),
          Text('Total: S/. ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saleItems.isNotEmpty ? _finalizeSale : null,
                  child: const Text('Generar boleta'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
