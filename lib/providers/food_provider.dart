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

  Future<void> loadCart() async {
    _cart = await _storageService.getCart();
    notifyListeners();
  }

  Future<void> addToCart(Menu menu) async {
    final index = _cart.indexWhere((item) => item.name == menu.name);
    
    if (index != -1) {
      _cart[index].quantity++;
    } else {
      _cart.add(CartItem(
        name: menu.name,
        price: menu.price.toDouble(), 
        quantity: 1,
        imageUrl: menu.imageUrl,
      ));
    }
    await _saveCart();
  }

  Future<void> updateQuantity(String itemName, int change) async {
    final index = _cart.indexWhere((item) => item.name == itemName);
    if (index != -1) {
      final newQuantity = _cart[index].quantity + change;
      if (newQuantity > 0) {
        _cart[index].quantity = newQuantity;
      } else {
        _cart.removeAt(index);
      }
      await _saveCart();
    }
  }

  Future<void> removeItem(String itemName) async {
    _cart.removeWhere((item) => item.name == itemName);
    await _saveCart();
  }

  Future<void> clearCart() async {
    _cart.clear();
    await _saveCart();
  }

  Future<void> _saveCart() async {
    await _storageService.saveCart(_cart);
    notifyListeners();
  }

  double get subtotal => _cart.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get serviceCharge => subtotal * 0.075;
  double get taxPB1 => (subtotal + serviceCharge) * 0.10;
  double get totalPayment => subtotal + serviceCharge + taxPB1;
}