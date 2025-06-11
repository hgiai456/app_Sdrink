import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/login'),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['user']);
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/logout'),
      );
    } catch (e) {
      throw Exception('Failed to logout');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/auth/me'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['user']);
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }
} 