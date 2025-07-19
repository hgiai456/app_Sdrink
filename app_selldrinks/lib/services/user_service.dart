import 'dart:convert';
import 'package:app_selldrinks/models/loginuser.dart';
import 'package:app_selldrinks/services/port.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart'; // import model bạn đã tạo

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
}
