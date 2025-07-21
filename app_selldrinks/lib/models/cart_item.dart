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
    return CartItem(
      id: json['id'],
      cartId: json['cart_id'],
      productDetailId: json['product_detail_id'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      productDetails: ProductDetail.fromJson(json['product_details']),
    );
  }

  int get totalPrice => productDetails.price * quantity;
}
