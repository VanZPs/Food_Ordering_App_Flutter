import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/food_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FoodProvider>(context);
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang Belanja")),
      body: Column(
        children: [
          Expanded(
            child: provider.cart.isEmpty
                ? const Center(child: Text("Keranjang Kosong"))
                : ListView.builder(
                    itemCount: provider.cart.length,
                    itemBuilder: (context, index) {
                      final item = provider.cart[index];
                      return ListTile(
                        title: Text(item.name),
                        trailing: Text(currency.format(item.price)),
                      );
                    },
                  ),
          ),
          if (provider.cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow("Subtotal", provider.subtotal, currency),
                  _buildSummaryRow("Service Charge (7.5%)", provider.serviceCharge, currency),
                  const Divider(),
                  _buildSummaryRow("PB1 (10% dari Subtotal+Service)", provider.taxPB1, currency),
                  const Divider(thickness: 2),
                  _buildSummaryRow("TOTAL PEMBAYARAN", provider.totalPayment, currency, isTotal: true),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                      onPressed: () {
                        provider.clearCart();
                        showDialog(
                          context: context, 
                          builder: (_) => const AlertDialog(content: Text("Pesanan Berhasil!")));
                      },
                      child: const Text("KONFIRMASI PESANAN", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, NumberFormat currency, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(currency.format(value), style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.blue : Colors.black)),
        ],
      ),
    );
  }
}