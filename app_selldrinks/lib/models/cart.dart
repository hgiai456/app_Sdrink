import 'package:app_selldrinks/models/cart_item.dart';

class Cart {
  final int id;
  final String? sessionId;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CartItem> cartItems;

  Cart({
    required this.id,
    this.sessionId,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.cartItems,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing Cart JSON: ${json['id']}');

      return Cart(
        id: _parseIntSafely(json['id']),
        sessionId: json['session_id']?.toString(),
        userId:
            json['user_id'] != null ? _parseIntSafely(json['user_id']) : null,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        cartItems:
            json['cart_items'] != null
                ? (json['cart_items'] as List).map((item) {
                  try {
                    print('Parsing cart item: ${item['id']}');
                    return CartItem.fromJson(item);
                  } catch (e) {
                    print('Error parsing cart item: $e');
                    print('Item data: $item');
                    rethrow;
                  }
                }).toList()
                : [],
      );
    } catch (e, stackTrace) {
      print('Error parsing Cart from JSON: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Getter để tính tổng giá
  int get totalPrice {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Getter để tính tổng số lượng
  int get totalItems {
    return cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'cart_items': cartItems.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Cart{id: $id, userId: $userId, items: ${cartItems.length}, total: $totalPrice}';
  }
}
