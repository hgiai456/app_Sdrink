class CartItem {
  final int id;
  final int cartId;
  final int productDetailId;
  final int quantity;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productDetailId,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      cartId: json['cart_id'],
      productDetailId: json['product_detail_id'],
      quantity: json['quantity'],
    );
  }
}
