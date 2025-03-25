import 'package:flutter/material.dart';
import 'package:bookshop_app/data/models/sale.dart';
import 'package:bookshop_app/data/repositories/sales_repository.dart';
import 'sale_detail_view.dart';

class ConfigurationView extends StatefulWidget {
  const ConfigurationView({super.key});

  @override
  State<ConfigurationView> createState() => _ConfigurationViewState();
}

class _ConfigurationViewState extends State<ConfigurationView> {
  final SalesRepository salesRepo = SalesRepository();
  List<Sale> _sales = [];

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final sales = await salesRepo.getAllSales();
    setState(() {
      _sales = sales;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Ventas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _sales.isEmpty
            ? const Center(child: Text('No hay ventas registradas.'))
            : ListView.builder(
                itemCount: _sales.length,
                itemBuilder: (context, index) {
                  final sale = _sales[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: Text('Venta #${sale.id}'),
                      subtitle: Text('🗓 ${sale.date}'),
                      trailing: Text(
                        'S/. ${sale.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SaleDetailView(sale: sale),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
