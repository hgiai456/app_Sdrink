import 'package:app_selldrinks/models/product_detail.dart';

class CartItem {
  final int id;
  final int cartId;
  final int productDetailId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductDetail productDetails;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productDetailId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.productDetails,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing CartItem JSON: $json');

      return CartItem(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        cartId:
            json['cart_id'] is int
                ? json['cart_id']
                : int.parse(json['cart_id'].toString()),
        productDetailId:
            json['product_detail_id'] is int
                ? json['product_detail_id']
                : int.parse(json['product_detail_id'].toString()),
        quantity:
            json['quantity'] is int
                ? json['quantity']
                : int.parse(json['quantity'].toString()),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        productDetails: ProductDetail.fromJson(json['product_details']),
      );
    } catch (e, stackTrace) {
      print('Error parsing CartItem from JSON: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_detail_id': productDetailId,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'product_details': productDetails.toJson(),
    };
  }

  int get totalPrice => productDetails.price * quantity;

  @override
  String toString() {
    return 'CartItem{id: $id, productDetailId: $productDetailId, quantity: $quantity, totalPrice: $totalPrice}';
  }
}
