import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_selldrinks/adminArea/adminModels/category_admin.dart';
import 'package:app_selldrinks/services/port.dart';

class CategoryAdminService {
  static Future<Map<String, dynamic>> fetchCategories(
    String token,
    int page,
  ) async {
    final response = await http.get(
      Uri.parse('${Port.baseUrl}/categories?page=$page'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'categories':
            (data['data'] as List)
                .map((json) => CategoryAdmin.fromJson(json))
                .toList(),
        'currentPage': data['currentPage'] ?? 1,
        'totalPage': data['totalPage'] ?? 1,
        'totalCategories': data['totalCategories'] ?? 0,
      };
    } else {
      throw Exception('Không lấy được danh sách danh mục');
    }
  }

  static Future<bool> addCategory(CategoryAdmin category, String token) async {
    final response = await http.post(
      Uri.parse('${Port.baseUrl}/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(category.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print('Thêm danh mục thất bại: ${response.body}');
      return false;
    }
  }

  static Future<bool> updateCategory(
    CategoryAdmin category,
    String token,
  ) async {
    if (category.id == null) return false;
    final response = await http.put(
      Uri.parse('${Port.baseUrl}/categories/${category.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(category.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Cập nhật danh mục thất bại: ${response.body}');
      return false;
    }
  }

  static Future<bool> deleteCategory(int id, String token) async {
    final response = await http.delete(
      Uri.parse('${Port.baseUrl}/categories/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
