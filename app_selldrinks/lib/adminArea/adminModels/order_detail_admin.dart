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
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
      productDetail: json['product_details'], // Lấy product_details
    );
  }

  // Getter để lấy tên sản phẩm
  String get productName {
    if (productDetail != null && productDetail!['name'] != null) {
      return productDetail!['name'];
    }
    return 'Sản phẩm không xác định';
  }

  // Getter để lấy specification
  String get specification {
    if (productDetail != null && productDetail!['specification'] != null) {
      return productDetail!['specification'];
    }
    return '';
  }

  // Getter để lấy oldprice
  int? get oldPrice {
    if (productDetail != null && productDetail!['oldprice'] != null) {
      return productDetail!['oldprice'];
    }
    return null;
  }
}
