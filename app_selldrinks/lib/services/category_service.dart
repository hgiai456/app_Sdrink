import 'dart:convert';
import 'package:app_selldrinks/models/category.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  // Lấy tất cả sản phẩm
  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['data'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
