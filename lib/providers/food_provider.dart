import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_model.dart';
import '../models/cart_model.dart';
import '../services/local_storage.dart';

class FoodProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _storageService = LocalStorageService();

  List<Menu> _menus = [];
  List<CartItem> _cart = [];

  List<Menu> get menus => _menus;
  List<CartItem> get cart => _cart;

  Future<void> fetchMenus() async {
    try {
      final snapshot = await _firestore.collection('menus').orderBy('order').get();
      _menus = snapshot.docs.map((doc) => Menu.fromMap(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching menus: $e");
    }
  }

  Future<void> seedDatabase() async {
    List<Menu> initialMenus = [
      Menu(name: "Nasi Goreng Spesial", price: 25000, category: "Makanan", order: 1),
      Menu(name: "Mie Goreng Jawa", price: 22000, category: "Makanan", order: 2),
      Menu(name: "Ayam Bakar Madu", price: 30000, category: "Makanan", order: 3),
      Menu(name: "Es Teh Manis", price: 5000, category: "Minuman", order: 4),
      Menu(name: "Jus Alpukat", price: 15000, category: "Minuman", order: 5),
    ];

    for (var menu in initialMenus) {
      final docRef = _firestore.collection('menus').doc(menu.name);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set(menu.toMap());
        debugPrint("Menu ${menu.name} ditambahkan.");
      } else {
        debugPrint("Menu ${menu.name} sudah ada.");
      }
    }
    await fetchMenus();
  }

  Future<void> loadCart() async {
    _cart = await _storageService.getCart();
    notifyListeners();
  }

  Future<void> addToCart(Menu menu) async {
    _cart.add(CartItem(name: menu.name, price: menu.price));
    await _storageService.saveCart(_cart);
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cart.clear();
    await _storageService.clearCart();
    notifyListeners();
  }

  double get subtotal => _cart.fold(0, (sum, item) => sum + item.price);
  double get serviceCharge => subtotal * 0.075;
  double get taxPB1 => (subtotal + serviceCharge) * 0.10; 
  double get totalPayment => subtotal + serviceCharge + taxPB1;
}