import 'dart:convert';
import 'package:app_selldrinks/models/product.dart';
import 'package:http/http.dart' as http;

class ProductService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  // Lấy tất cả sản phẩm
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['data'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> getProductsByCategory(int categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products-by-category?category_id=$categoryId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['data'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load products by category');
    }
  }
}
