class CartItem {
  final int id;
  final int cartId;
  final int productDetailId;
  final int quantity;
  final Map<String, dynamic>? productDetail;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productDetailId,
    required this.quantity,
    this.productDetail,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      cartId: json['cart_id'],
      productDetailId: json['product_detail_id'],
      quantity: json['quantity'],
      productDetail: json['product_detail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_detail_id': productDetailId,
      'quantity': quantity,
      'product_detail': productDetail,
    };
  }
}
