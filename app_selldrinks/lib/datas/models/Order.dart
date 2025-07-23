class Order {
  final int id;
  final int price;
  final String phone;
  final String address;
  final String imageUrl;
  final int totalAmount;
  final String? badge;
  final int? userId;
  final String? status;
  final String? note;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.price,
    required this.address,
    required this.note,
    required this.imageUrl,
    required this.phone,
    required this.totalAmount,
    required this.createdAt,
    this.userId,
    this.status,
    this.badge,
  });
}
