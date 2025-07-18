import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_selldrinks/adminArea/adminModels/order_admin.dart';
import 'package:app_selldrinks/services/port.dart';

class OrderAdminService {
  static Future<Map<String, dynamic>> fetchOrders(
    String token,
    int page,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${Port.baseUrl}/orders?page=$page'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Xử lý trường hợp data là object hoặc list
        final raw = data['data'];
        List listData;
        if (raw is List) {
          listData = raw;
        } else if (raw is Map) {
          listData = [raw];
        } else {
          listData = [];
        }
        return {
          'orders':
              listData
                  .map((json) {
                    try {
                      return OrderAdmin.fromJson(json);
                    } catch (e) {
                      print('Lỗi parse OrderAdmin: $e');
                      return null;
                    }
                  })
                  .whereType<OrderAdmin>()
                  .toList(),
          'currentPage': data['currentPage'] ?? 1,
          'totalPage': data['totalPage'] ?? 1,
          'totalOrders': data['totalOrders'] ?? 0,
        };
      } else {
        print('Lỗi lấy đơn hàng: ${response.body}');
        return {
          'orders': [],
          'currentPage': 1,
          'totalPage': 1,
          'totalOrders': 0,
        };
      }
    } catch (e) {
      print('Lỗi mạng hoặc parse JSON: $e');
      return {'orders': [], 'currentPage': 1, 'totalPage': 1, 'totalOrders': 0};
    }
  }

  static Future<OrderAdmin> fetchOrderDetail(String token, int orderId) async {
    final response = await http.get(
      Uri.parse('${Port.baseUrl}/orders/$orderId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return OrderAdmin.fromJson(data['data']);
    } else {
      throw Exception('Không lấy được chi tiết đơn hàng');
    }
  }

  static Future<bool> updateOrderStatus(
    String token,
    int orderId,
    int status,
  ) async {
    final response = await http.put(
      Uri.parse('${Port.baseUrl}/orders/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200;
  }
}
