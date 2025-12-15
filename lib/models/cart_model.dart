import 'dart:convert';

class CartItem {
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }
  
  static String encode(List<CartItem> items) => json.encode(
        items.map<Map<String, dynamic>>((item) => item.toMap()).toList(),
      );

  static List<CartItem> decode(String items) =>
      (json.decode(items) as List<dynamic>)
          .map<CartItem>((item) => CartItem.fromMap(item))
          .toList();
}