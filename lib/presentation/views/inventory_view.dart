import 'package:flutter/material.dart';
import 'package:bookshop_app/data/models/product.dart';
import 'package:bookshop_app/data/repositories/product_repository.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  final ProductRepository productRepo = ProductRepository();
  List<Product> _products = [];

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

  Future<void> _saveProduct() async {
    final String name = nameController.text;
    final double price = double.tryParse(priceController.text) ?? 0.0;
    final int stock = int.tryParse(stockController.text) ?? 0;

    if (name.isEmpty || price <= 0 || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos correctamente')),
      );
      return;
    }

    final product = Product(name: name, price: price, stock: stock);
    await productRepo.insertProduct(product);

    nameController.clear();
    priceController.clear();
    stockController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto guardado con éxito')),
    );

    await _loadProducts();
  }

  Future<void> _deleteProduct(int id) async {
    await productRepo.deleteProduct(id);
    await _loadProducts();
  }

  void _showEditDialog(Product product) {
    final TextEditingController editName = TextEditingController(text: product.name);
    final TextEditingController editPrice = TextEditingController(text: product.price.toString());
    final TextEditingController editStock = TextEditingController(text: product.stock.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Editar producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _customInput(controller: editName, label: 'Nombre'),
            _customInput(controller: editPrice, label: 'Precio', isNumber: true),
            _customInput(controller: editStock, label: 'Stock', isNumber: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final updated = Product(
                id: product.id,
                name: editName.text,
                price: double.tryParse(editPrice.text) ?? 0,
                stock: int.tryParse(editStock.text) ?? 0,
              );
              await productRepo.updateProduct(updated);
              Navigator.pop(context);
              await _loadProducts();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _customInput({required TextEditingController controller, required String label, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Registrar nuevo producto',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _customInput(controller: nameController, label: 'Nombre del producto'),
            _customInput(controller: priceController, label: 'Precio', isNumber: true),
            _customInput(controller: stockController, label: 'Stock', isNumber: true),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar producto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _saveProduct,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Inventario actual:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            if (_products.isEmpty)
              const Text('No hay productos registrados.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(product.name ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Precio: \$${product.price?.toStringAsFixed(2) ?? '0.00'}  |  Stock: ${product.stock}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _showEditDialog(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(product.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
