import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/food_provider.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FoodProvider>(context, listen: false);
      provider.fetchMenus(); 
      provider.loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FoodProvider>(context);
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    Map<String, List<dynamic>> groupedMenu = {};
    for (var menu in provider.menus) {
      if (!groupedMenu.containsKey(menu.category)) {
        groupedMenu[menu.category] = [];
      }
      groupedMenu[menu.category]!.add(menu);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pemesanan Makanan V.0.1"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              if (provider.cart.isNotEmpty)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('${provider.cart.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                )
            ],
          )
        ],
      ),
      body: provider.menus.isEmpty
          ? const Center(child: Text("Memuat Menu... (Pastikan Seed Data sudah dijalankan)"))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: groupedMenu.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(entry.key, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    ),
                    ...entry.value.map((menu) => Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text(menu.name[0]),
                            ),
                            title: Text(menu.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(currency.format(menu.price)),
                            trailing: ElevatedButton.icon(
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text("Pesan"),
                              onPressed: () {
                                provider.addToCart(menu);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text("Menu ditambahkan ke keranjang"),
                                  duration: Duration(milliseconds: 600),
                                ));
                              },
                            ),
                          ),
                        ))
                  ],
                );
              }).toList(),
            ),
    );
  }
}