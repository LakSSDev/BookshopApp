import 'package:bookshop_app/presentation/views/configuration_view.dart';
import 'package:bookshop_app/presentation/views/inventory_view.dart';
import 'package:bookshop_app/presentation/views/sales_view.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Índice para saber qué vista mostrar
  int _selectedIndex = 0;

  // Lista de títulos que se mostrarán en el AppBar
  final List<String> _titles = ['Inventario', 'Ventas', 'Configuración'];

  // Lista de widgets (las vistas para cada opción del menú)
  final List<Widget> _pages =
   [
    const InventoryView(), 
    const SalesView(),
    const ConfigurationView()
    ];

  // Cambiar el contenido cuando se selecciona una opción del Drawer

  void _onSelectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Cierra el Drawer después de seleccionar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(decoration: BoxDecoration(color: Colors.blue), child: Text('Menú Principal', style: TextStyle(color: Colors.white, fontSize: 24))),
            ListTile(leading: const Icon(Icons.inventory), title: const Text('Inventario'), selected: _selectedIndex == 0, onTap: () => _onSelectPage(0)),
            ListTile(leading: const Icon(Icons.point_of_sale), title: const Text('Ventas'), selected: _selectedIndex == 1, onTap: () => _onSelectPage(1)),
            ListTile(leading: const Icon(Icons.settings), title: const Text('Historial De Ventas'), selected: _selectedIndex == 2, onTap: () => _onSelectPage(2)),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
