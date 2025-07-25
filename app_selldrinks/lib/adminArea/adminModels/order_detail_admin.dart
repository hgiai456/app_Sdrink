class OrderDetailAdmin {
  final int id;
  final int orderId;
  final int productDetailId;
  final int price;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? productDetail;

  OrderDetailAdmin({
    required this.id,
    required this.orderId,
    required this.productDetailId,
    required this.price,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.productDetail,
  });

  factory OrderDetailAdmin.fromJson(Map<String, dynamic> json) {
    return OrderDetailAdmin(
      id: json['id'],
      orderId: json['order_id'],
      productDetailId: json['product_detail_id'],
      price: json['price'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      productDetail: json['product_details'],
    );
  }
}
