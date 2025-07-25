import 'package:app_selldrinks/models/Order.dart';
import 'package:app_selldrinks/models/cart_item.dart';
import 'package:flutter/material.dart';

class OrderModel {
  final int? id;
  final int? userId;
  final String? sessionId;
  final int status;
  final String? note;
  final int total;
  final String? address;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CartItem>? orderItems;

  OrderModel({
    this.id,
    this.userId,
    this.sessionId,
    required this.status,
    this.note,
    required this.total,
    this.address,
    this.phone,
    this.createdAt,
    this.updatedAt,
    this.orderItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      sessionId: json['session_id']?.toString(),
      status: json['status'] ?? 1,
      note: json['note'],
      total: json['total'] ?? 0,
      address: json['address'],
      phone: json['phone'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      orderItems:
          json['order_items'] != null
              ? (json['order_items'] as List)
                  .map((item) => CartItem.fromJson(item))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'session_id': sessionId,
      'status': status,
      'note': note,
      'total': total,
      'address': address,
      'phone': phone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Lấy text trạng thái theo status code
  String get statusText {
    switch (status) {
      case 1:
        return 'Chờ xử lý';
      case 2:
        return 'Đang xử lý';
      case 3:
        return 'Đã giao hàng';
      case 4:
        return 'Đã giao thành công';
      case 5:
        return 'Đã hủy';
      case 6:
        return 'Đã hoàn tiền';
      case 7:
        return 'Thất bại';
      default:
        return 'Không xác định';
    }
  }

  /// Lấy màu sắc cho status
  Color get statusColor {
    switch (status) {
      case 1:
        return Colors.orange; // Pending
      case 2:
        return Colors.blue; // Processing
      case 3:
        return Colors.purple; // Shipped
      case 4:
        return Colors.green; // Delivered
      case 5:
        return Colors.red; // Cancelled
      case 6:
        return Colors.brown; // Refunded
      case 7:
        return Colors.red; // Failed
      default:
        return Colors.grey;
    }
  }

  /// Kiểm tra có thể hủy đơn hàng không
  bool get canCancel {
    return status == 1 ||
        status == 2; // Chỉ hủy được khi Pending hoặc Processing
  }

  /// Kiểm tra đơn hàng đã hoàn thành chưa
  bool get isCompleted {
    return status == 4; // Delivered
  }

  /// Kiểm tra đơn hàng có bị hủy/thất bại không
  bool get isFailed {
    return status == 5 || status == 7; // Cancelled hoặc Failed
  }

  @override
  String toString() {
    return 'Order{id: $id, status: $status, total: $total, phone: $phone}';
  }
}
