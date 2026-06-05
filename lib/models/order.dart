
class Order {
  final String id;
  final String userId;
  final List<Map<String,dynamic>> items;
  final double total;
  final String status;
  Order({required this.id, required this.userId, required this.items, required this.total, this.status = 'pending'});
}
