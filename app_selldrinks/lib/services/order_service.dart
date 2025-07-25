import 'dart:convert';
import 'package:app_selldrinks/models/order_checkout.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_selldrinks/models/order.dart';
import 'package:app_selldrinks/services/cart_service.dart';
import 'package:app_selldrinks/services/port.dart';

class OrderService {
  static const String baseUrl = Port.baseUrl;

  //Tao don hang tu gio hang
  static Future<OrderModel> createOrder({
    required int cartId,
    required String phone,
    required String address,
    String? note,
  }) async {
    try {
      print('OrderService - Creating order with cartId: $cartId');

      final response = await http.post(
        Uri.parse('$baseUrl/carts/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cart_id': cartId,
          'phone': phone,
          'address': address,
          'note': note ?? '',
        }),
      );
      print('OrderService - createOrder Status: ${response.statusCode}');
      print('OrderService - createOrder Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('userId');
        if (userId == null) {
          await prefs.remove('session_id');
        }
        OrderModel order;
        if (data['data'] != null) {
          order = OrderModel.fromJson(data['data']);
        } else if (data['order'] != null) {
          order = OrderModel.fromJson(data['order']);
        } else {
          order = OrderModel.fromJson(data);
        }
        print('OrderService - Created order: ${order.id}');
        return order;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Tạo đơn hàng thất bại');
      }
    } catch (e) {
      print('OrderService - Error creating order: $e');
      throw Exception('Lỗi tạo đơn hàng: $e');
    }
  }

  static Future<List<OrderModel>> getOrdersByUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        print('OrderService - No user ID found');
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/orders?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> ordersData = [];
        if (data['data'] is List) {
          ordersData = data['data'];
        } else if (data is List) {
          ordersData = data;
        }

        final orders =
            ordersData
                .map((orderJson) => OrderModel.fromJson(orderJson))
                .toList();

        // Sắp xếp theo thời gian tạo mới nhất
        orders.sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

        return orders;
      } else {
        throw Exception('Lấy danh sách đơn hàng thất bại');
      }
    } catch (e) {
      print('OrderService - Error getting user orders: $e');
      return [];
    }
  }

  /// Lấy tất cả đơn hàng (admin)
  static Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
      );

      print('OrderService - getAllOrders Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> ordersData = [];
        if (data['data'] is List) {
          ordersData = data['data'];
        } else if (data is List) {
          ordersData = data;
        }

        return ordersData
            .map((orderJson) => OrderModel.fromJson(orderJson))
            .toList();
      } else {
        throw Exception('Lấy danh sách đơn hàng thất bại');
      }
    } catch (e) {
      print('OrderService - Error getting all orders: $e');
      return [];
    }
  }

  /// Lấy chi tiết đơn hàng
  static Future<OrderModel?> getOrderDetail(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('OrderService - getOrderDetail Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Map<String, dynamic> orderData;
        if (data['data'] != null) {
          orderData = data['data'];
        } else {
          orderData = data;
        }

        return OrderModel.fromJson(orderData);
      } else {
        throw Exception('Lấy chi tiết đơn hàng thất bại');
      }
    } catch (e) {
      print('OrderService - Error getting order detail: $e');
      return null;
    }
  }

  /// Cập nhật trạng thái đơn hàng
  static Future<bool> updateOrderStatus(int orderId, int newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );

      print('OrderService - updateOrderStatus Status: ${response.statusCode}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('OrderService - Error updating order status: $e');
      return false;
    }
  }

  /// Hủy đơn hàng
  static Future<bool> cancelOrder(int orderId) async {
    return await updateOrderStatus(orderId, 5); // Status 5 = Cancelled
  }

  /// Lấy đơn hàng hiện tại (user hoặc guest)
  static Future<List<Order>> getCurrentUserOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        // User đã đăng nhập
        return await getCurrentUserOrders();
      } else {
        // Guest user
        final sessionId = prefs.getString('session_id');

        return [];
      }
    } catch (e) {
      print('OrderService - Error getting current user orders: $e');
      return [];
    }
  }
}
