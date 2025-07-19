import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_selldrinks/adminArea/adminModels/product_admin.dart';
import 'package:app_selldrinks/services/port.dart';

class ProductAdminService {
  static Future<Map<String, dynamic>> fetchProducts(
    String token,
    int page,
  ) async {
    final response = await http.get(
      Uri.parse('${Port.baseUrl}/products?page=$page'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Trả về cả danh sách và thông tin phân trang
      return {
        'products':
            (data['data'] as List)
                .map((json) => ProductAdmin.fromJson(json))
                .toList(),
        'currentPage': data['currentPage'] ?? 1,
        'totalPage': data['totalPage'] ?? 1,
        'totalProducts': data['totalProducts'] ?? 0,
      };
    } else {
      throw Exception('Không lấy được danh sách sản phẩm');
    }
  }

  static Future<bool> addProduct(ProductAdmin product, String token) async {
    final response = await http.post(
      Uri.parse('${Port.baseUrl}/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print('Thêm sản phẩm thất bại: ${response.body}');
      return false;
    }
  }

  static Future<bool> updateProduct(ProductAdmin product, String token) async {
    if (product.id == null) return false;
    final response = await http.put(
      Uri.parse('${Port.baseUrl}/products/${product.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Cập nhật sản phẩm thất bại: ${response.body}');
      return false;
    }
  }

  static Future<bool> deleteProduct(int id, String token) async {
    final response = await http.delete(
      Uri.parse('${Port.baseUrl}/products/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
