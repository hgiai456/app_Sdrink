import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_selldrinks/models/category.dart';

class CategoryService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Lấy danh sách tất cả danh mục
  static Future<List<Category>> getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 