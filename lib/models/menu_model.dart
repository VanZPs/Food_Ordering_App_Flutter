class Menu {
  final String name;
  final int price;
  final String category;
  final int order;
  final String imageUrl;

  Menu({
    required this.name,
    required this.price,
    required this.category,
    required this.order,
    this.imageUrl = '',
  });

  factory Menu.fromMap(Map<String, dynamic> data) {
    return Menu(
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      category: data['category'] ?? 'Lainnya',
      order: data['order'] ?? 0,
      imageUrl: data['imageUrl'] ?? '', 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'order': order,
      'imageUrl': imageUrl,
    };
  }
}