class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;

  MenuItem({required this.id, required this.name, this.description = '', required this.price});

  factory MenuItem.fromMap(String id, Map<String,dynamic> m) => MenuItem(
    id: id,
    name: m['name'] ?? '',
    description: m['description'] ?? '',
    price: (m['price'] ?? 0).toDouble(),
  );
}
