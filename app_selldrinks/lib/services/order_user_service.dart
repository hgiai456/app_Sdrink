import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_selldrinks/models/order_user_model.dart';
import 'package:app_selldrinks/services/port.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderUserService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Lấy danh sách đơn hàng theo user ID
  static Future<Map<String, dynamic>> fetchUserOrders({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      print('OrderUserService - Token: $token');
      print('OrderUserService - User ID: $userId');

      if (token == null || userId == null) {
        throw Exception('Không tìm thấy thông tin đăng nhập');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final uri = Uri.parse('${Port.baseUrl}/orders/user/$userId').replace(
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );

      print('OrderUserService - Request URL: $uri');
      print('OrderUserService - Request headers: $headers');

      final response = await http.get(uri, headers: headers);

      print('OrderUserService - Response status: ${response.statusCode}');
      print('OrderUserService - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Parse orders
        final List<OrderUserModel> orders =
            (responseData['data'] as List?)
                ?.map((orderJson) => OrderUserModel.fromJson(orderJson))
                .toList() ??
            [];

        return {
          'success': true,
          'orders': orders,
          'currentPage': responseData['currentPage'] ?? 1,
          'totalPage': responseData['totalPage'] ?? 1,
          'totalOrders': responseData['totalOrders'] ?? 0,
        };
      } else if (response.statusCode == 404) {
        // Không có đơn hàng nào
        return {
          'success': true,
          'orders': <OrderUserModel>[],
          'currentPage': 1,
          'totalPage': 1,
          'totalOrders': 0,
        };
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('OrderUserService - Error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'orders': <OrderUserModel>[],
        'currentPage': 1,
        'totalPage': 1,
        'totalOrders': 0,
      };
    }
  }

  // Lấy chi tiết đơn hàng theo ID
  static Future<OrderUserModel?> getOrderById(int orderId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('${Port.baseUrl}/orders/$orderId'),
        headers: headers,
      );

      print(
        'OrderUserService - Get order by ID status: ${response.statusCode}',
      );
      print('OrderUserService - Get order by ID body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return OrderUserModel.fromJson(responseData['data']);
      } else {
        throw Exception('Không tìm thấy đơn hàng');
      }
    } catch (e) {
      print('OrderUserService - Get order by ID error: $e');
      return null;
    }
  }

  // Hủy đơn hàng (nếu có chức năng này)
  static Future<bool> cancelOrder(int orderId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.put(
        Uri.parse('${Port.baseUrl}/orders/$orderId/cancel'),
        headers: headers,
      );

      print('OrderUserService - Cancel order status: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('OrderUserService - Cancel order error: $e');
      return false;
    }
  }

  // Tìm kiếm đơn hàng
  static Future<List<OrderUserModel>> searchOrders(String query) async {
    try {
      final token = await _getToken();
      final userId = await _getUserId();

      if (token == null || userId == null) {
        throw Exception('Không tìm thấy thông tin đăng nhập');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final uri = Uri.parse(
        '${Port.baseUrl}/orders/user/$userId/search',
      ).replace(queryParameters: {'q': query});

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return (responseData['data'] as List?)
                ?.map((orderJson) => OrderUserModel.fromJson(orderJson))
                .toList() ??
            [];
      } else {
        throw Exception('Lỗi tìm kiếm: ${response.statusCode}');
      }
    } catch (e) {
      print('OrderUserService - Search error: $e');
      return [];
    }
  }
}
