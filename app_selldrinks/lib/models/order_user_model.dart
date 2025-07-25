import 'dart:ui';

class OrderUserModel {
  final int id;
  final int userId;
  final String sessionId;
  final int status;
  final String note;
  final int total;
  final String address;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderDetailUser> orderDetails;

  OrderUserModel({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.status,
    required this.note,
    required this.total,
    required this.address,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    required this.orderDetails,
  });

  factory OrderUserModel.fromJson(Map<String, dynamic> json) {
    return OrderUserModel(
      id: json['id'],
      userId: json['user_id'],
      sessionId: json['session_id'] ?? '',
      status: json['status'],
      note: json['note'] ?? '',
      total: json['total'],
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      orderDetails:
          (json['order_details'] as List?)
              ?.map((detail) => OrderDetailUser.fromJson(detail))
              .toList() ??
          [],
    );
  }

  String get statusText {
    switch (status) {
      case 1:
        return 'Đang chờ xử lý';
      case 2:
        return 'Đang chuẩn bị';
      case 3:
        return 'Đang giao';
      case 4:
        return 'Đã giao';
      case 5:
        return 'Đã hủy';
      case 6:
        return 'Đã hoàn tiền';
      case 7:
        return 'Không thành công';
      default:
        return 'Không xác định';
    }
  }

  Color get statusColor {
    switch (status) {
      case 1:
        return const Color(0xFFFF9800); // Orange
      case 2:
        return const Color(0xFF2196F3); // Blue
      case 3:
        return const Color(0xFF9C27B0); // Purple
      case 4:
        return const Color(0xFF4CAF50); // Green
      case 5:
      case 7:
        return const Color(0xFFF44336); // Red
      case 6:
        return const Color(0xFF607D8B); // Grey
      default:
        return const Color(0xFF808080); // Default grey
    }
  }

  // Tính tổng số lượng sản phẩm
  int get totalQuantity {
    return orderDetails.fold(0, (sum, detail) => sum + detail.quantity);
  }

  // Lấy tên sản phẩm đầu tiên (để hiển thị trong list)
  String get firstProductName {
    if (orderDetails.isNotEmpty) {
      return orderDetails.first.productName;
    }
    return 'Không có sản phẩm';
  }

  // Lấy hình ảnh sản phẩm đầu tiên
  String get firstProductImage {
    if (orderDetails.isNotEmpty) {
      return orderDetails.first.productImage;
    }
    return '';
  }
}

class OrderDetailUser {
  final int quantity;
  final int price;
  final ProductDetailUser productDetails;

  OrderDetailUser({
    required this.quantity,
    required this.price,
    required this.productDetails,
  });

  factory OrderDetailUser.fromJson(Map<String, dynamic> json) {
    return OrderDetailUser(
      quantity: json['quantity'],
      price: json['price'],
      productDetails: ProductDetailUser.fromJson(json['product_details']),
    );
  }

  String get productName => productDetails.name;
  String get productImage => productDetails.product?.image ?? '';
  int get totalPrice => price * quantity;
}

class ProductDetailUser {
  final String name;
  final ProductUser? product;

  ProductDetailUser({required this.name, this.product});

  factory ProductDetailUser.fromJson(Map<String, dynamic> json) {
    return ProductDetailUser(
      name: json['name'] ?? '',
      product:
          json['product'] != null
              ? ProductUser.fromJson(json['product'])
              : null,
    );
  }
}

class ProductUser {
  final String image;

  ProductUser({required this.image});

  factory ProductUser.fromJson(Map<String, dynamic> json) {
    return ProductUser(image: json['image'] ?? '');
  }
}
