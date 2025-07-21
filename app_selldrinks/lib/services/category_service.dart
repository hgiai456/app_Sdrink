import 'dart:convert';
import 'package:app_selldrinks/models/category.dart';
import 'package:app_selldrinks/services/port.dart';
import 'package:http/http.dart' as http;
import 'package:app_selldrinks/services/port.dart';

class CategoryService {
  static const String baseUrl = Port.baseUrl;
  // Lấy tất cả sản phẩm
  static Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('${Port.baseUrl}/categories'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['data'] as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<Category>> getAllCategories() async {
    try {
      final response = await http.get(Uri.parse('${Port.baseUrl}/categories'));

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



  // Lấy danh sách tất cả danh mục
  

