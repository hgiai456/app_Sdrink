import 'package:app_selldrinks/models/cart_item.dart';

class Cart {
  final int id;
  final String sessionId;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CartItem> cartItems;

  Cart({
    required this.id,
    required this.sessionId,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.cartItems,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      sessionId: json['session_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      cartItems:
          (json['cart_items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList(),
    );
  }

  int get totalPrice => cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  int get totalQuantity =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);
}
