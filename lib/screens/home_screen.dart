import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/menu_model.dart';
import '../providers/food_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentPage = 'menu';
  String selectedCategory = 'Semua';
  String searchQuery = '';
  final List<String> categories = ['Semua', 'Makanan', 'Minuman', 'Snack']; 

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FoodProvider>().fetchMenus();
      context.read<FoodProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7ED), Colors.white, Color(0xFFFEF2F2)],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildNavigationTabs(),
            Expanded(
              child: currentPage == 'menu' ? _buildMenuPage() : _buildCartPage(),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. HEADER SECTION ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEF4444)], // Orange to Red
        ),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Consumer<FoodProvider>(
        builder: (context, provider, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.restaurant_menu, color: Color(0xFFF97316), size: 32),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pemesanan Makanan',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Pesan makanan favoritmu!',
                        style: TextStyle(color: Color(0xFFFFCCBC), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Stack(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => setState(() => currentPage = 'cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFF97316),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                    label: const Text('Keranjang'),
                  ),
                  if (provider.cart.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${provider.cart.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  // --- 2. NAVIGATION TABS ---
  Widget _buildNavigationTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabItem('Menu', 'menu'),
          const SizedBox(width: 24),
          _buildTabItem('Keranjang Belanja', 'cart'),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, String pageKey) {
    bool isActive = currentPage == pageKey;
    return InkWell(
      onTap: () => setState(() => currentPage = pageKey),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isActive ? const Color(0xFFF97316) : Colors.transparent, width: 2)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFFF97316) : Colors.grey.shade500,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // --- 3. MENU PAGE CONTENT ---
  Widget _buildMenuPage() {
    return Consumer<FoodProvider>(
      builder: (context, provider, _) {
        final filteredMenus = provider.menus.where((item) {
          final matchesCategory = selectedCategory == 'Semua' || item.category == selectedCategory;
          final matchesSearch = item.name.toLowerCase().contains(searchQuery.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Cari menu makanan...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  bool isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => setState(() => selectedCategory = cat),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEF4444)])
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? null : Border.all(color: Colors.grey.shade200, width: 2),
                          boxShadow: isSelected ? [const BoxShadow(color: Colors.orangeAccent, blurRadius: 8, offset: Offset(0, 2))] : null,
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            if (filteredMenus.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Tidak ada menu ditemukan")))
            else
              LayoutBuilder(builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 600 ? 3 : (constraints.maxWidth > 400 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredMenus.length,
                  itemBuilder: (context, index) {
                    final menu = filteredMenus[index];
                    return _buildMenuCard(menu, provider);
                  },
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildMenuCard(Menu menu, FoodProvider provider) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFEDD5), Color(0xFFFEE2E2)], 
                ),
              ),
              child: Center(
                child: Text(
                  menu.name.characters.first.toUpperCase(), 
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              menu.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFFFEDD5), borderRadius: BorderRadius.circular(8)),
                            child: Text(menu.category, style: const TextStyle(fontSize: 10, color: Color(0xFFEA580C), fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Menu lezat spesial untukmu", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormatter.format(menu.price),
                        style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          provider.addToCart(menu);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('${menu.name} ditambahkan'), 
                            duration: const Duration(milliseconds: 500),
                            behavior: SnackBarBehavior.floating,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEF4444)]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [Icon(Icons.add, size: 16), SizedBox(width: 4), Text("Tambah")],
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. CART PAGE CONTENT ---
  Widget _buildCartPage() {
    return Consumer<FoodProvider>(
      builder: (context, provider, _) {
        final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

        if (provider.cart.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("🛒", style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text("Keranjang masih kosong", style: TextStyle(color: Colors.grey, fontSize: 18)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => setState(() => currentPage = 'menu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text("Mulai Belanja"),
                )
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shopping_cart, color: Color(0xFFF97316)),
                        SizedBox(width: 8),
                        Text("Keranjang Belanja", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.cart.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                      itemBuilder: (ctx, i) {
                        final item = provider.cart[i];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFFFFEDD5), Color(0xFFFEE2E2)]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(child: Text(item.name[0], style: const TextStyle(fontSize: 24))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(currencyFormatter.format(item.price), style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _qtyButton(Icons.remove, () => provider.updateQuantity(item.name, -1)),
                                  SizedBox(width: 30, child: Center(child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
                                  _qtyButton(Icons.add, () => provider.updateQuantity(item.name, 1)),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => provider.removeItem(item.name),
                                    style: IconButton.styleFrom(backgroundColor: const Color(0xFFFEE2E2)),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.receipt_long, color: Color(0xFFF97316)),
                        SizedBox(width: 8),
                        Text("Ringkasan Pembayaran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _summaryRow("Subtotal", provider.subtotal),
                    _summaryRow("Service Charge (7.5%)", provider.serviceCharge),
                    _summaryRow("PB1 (10%)", provider.taxPB1),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(currencyFormatter.format(provider.totalPayment), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFF97316))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF), // Blue-50
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)), // Blue-200
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFF1E40AF)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Transparansi Biaya: Rincian biaya diberikan untuk transparansi.",
                              style: TextStyle(color: Color(0xFF1E40AF), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.access_time),
                        label: const Text("Lanjut ke Pembayaran"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }

  Widget _summaryRow(String label, double value) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(fmt.format(value), style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}