import 'order_detail_admin.dart';

class OrderAdmin {
  final int id;
  final int? userId;
  final String? sessionId;
  int status;
  final String? note;
  final int total;
  final String? address;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? user; // Thêm thông tin user
  final List<OrderDetailAdmin> orderDetails;

  OrderAdmin({
    required this.id,
    this.userId,
    this.sessionId,
    required this.status,
    this.note,
    required this.total,
    this.address,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.user, // Thêm user
    required this.orderDetails,
  });

  factory OrderAdmin.fromJson(Map<String, dynamic> json) {
    return OrderAdmin(
      id: json['id'],
      userId: json['user_id'],
      sessionId: json['session_id'],
      status: json['status'],
      note: json['note'],
      total: json['total'],
      address: json['address'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'], // Thêm user từ JSON
      orderDetails:
          (json['order_details'] is List && json['order_details'] != null)
              ? (json['order_details'] as List)
                  .map((e) => OrderDetailAdmin.fromJson(e))
                  .toList()
              : [],
    );
  }

  // Getter để lấy tên user
  String get userName {
    if (user != null && user!['name'] != null) {
      return user!['name'];
    }
    return 'Khách hàng';
  }

  Map<String, dynamic> toJson() {
    return {'status': status};
  }
}
