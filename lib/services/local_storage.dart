import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';

class LocalStorageService {
  static const String _keyCart = 'user_cart_data';

  Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = CartItem.encode(items);
    await prefs.setString(_keyCart, encodedData);
  }

  Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartString = prefs.getString(_keyCart);
    if (cartString != null) {
      return CartItem.decode(cartString);
    }
    return [];
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCart);
  }
}