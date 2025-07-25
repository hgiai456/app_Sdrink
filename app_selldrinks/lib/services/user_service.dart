import 'dart:convert';
import 'package:app_selldrinks/models/loginuser.dart';
import 'package:app_selldrinks/services/cart_service.dart';
import 'package:app_selldrinks/services/port.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart'; // import model bạn đã tạo
import 'package:app_selldrinks/services/port.dart';

class UserService {
  final String _baseUrl = '${Port.baseUrl}/users'; // Đúng port backend

  //Đăng nhập
  Future<Map<String, dynamic>> login(LoginUser user) async {
    String url = '$_baseUrl/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
      print(
        'RESPONSE: ${response.body}',
      ); // Thêm dòng này để xem response thực tế
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'token': data['data']['token'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Đăng nhập thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<void> switchUser(
    int newUserId,
    String userName,
    String? phone,
  ) async {
    try {
      // Xóa toàn bộ session cũ trước
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Xóa session cart cũ
      await CartService.clearUserSession();

      // Lưu thông tin user mới
      await prefs.setInt('userId', newUserId);
      await prefs.setString('userName', userName);
      if (phone != null) {
        await prefs.setString('userPhone', phone);
      }

      print('UserService - Successfully switched to user: $newUserId');
    } catch (e) {
      print('UserService - Error switching user: $e');
      throw Exception('Switch user failed: $e');
    }
  }

  //Đăng ký người dùng mới
  Future<Map<String, dynamic>> register(User user) async {
    final url = Uri.parse('$_baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Đăng ký thất bại'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Lỗi kết nối: $e'};
    }
  }

  static Future<void> logout() async {
    try {
      await CartService.clearUserSession(); // Gọi trước để xóa session cart
      final prefs = await SharedPreferences.getInstance();

      // Xóa tất cả thông tin user và session
      await prefs.clear(); // Xóa toàn bộ

      print('UserService - All user data cleared successfully');
    } catch (e) {
      print('UserService - Error during logout: $e');
      throw Exception('Logout failed: $e');
    }
  }
}
