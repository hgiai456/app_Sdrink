class CartItem {
  final int id;
  final int cartId;
  final int productDetailId;
  final int quantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? prodetail; // Thông tin chi tiết sản phẩm

  CartItem({
    required this.id,
    required this.cartId,
    required this.productDetailId,
    required this.quantity,
    this.createdAt,
    this.updatedAt,
    this.prodetail,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      cartId: json['cart_id'],
      productDetailId: json['product_detail_id'],
      quantity: json['quantity'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      prodetail: json['prodetail'], // Đổi từ productDetail sang prodetail
    );
  }

  // Helper methods để lấy thông tin sản phẩm từ prodetail
  String get productName {
    // Lấy tên từ product.name (không có size)
    return prodetail?['product']?['name'] ?? 'Sản phẩm';
  }

  String get productDetailName {
    // Lấy tên chi tiết có size từ prodetail.name
    return prodetail?['name'] ?? 'Sản phẩm';
  }

  String get productImage {
    // Lấy hình từ product.image
    return prodetail?['product']?['image'] ?? '';
  }

  int get productPrice {
    // Lấy giá từ prodetail.price
    return prodetail?['price'] ?? 0;
  }

  int get oldPrice {
    // Lấy giá cũ từ prodetail.oldprice
    return prodetail?['oldprice'] ?? 0;
  }

  String get specification {
    // Lấy thông số từ prodetail.specification
    return prodetail?['specification'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_detail_id': productDetailId,
      'quantity': quantity,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'prodetail': prodetail,
    };
  }
}
