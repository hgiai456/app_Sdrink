import 'dart:convert';
import 'package:app_selldrinks/models/product.dart';
import 'package:app_selldrinks/models/product_detail_response.dart';
import 'package:app_selldrinks/services/port.dart';
import 'package:http/http.dart' as http;
import 'package:app_selldrinks/services/port.dart';

class ProductService {
  static const String baseUrl = Port.baseUrl;
  // Lấy tất cả sản phẩm
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('${Port.baseUrl}/products'));

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
      Uri.parse('${Port.baseUrl}/products-by-category?category_id=$categoryId'),
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

  static Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('${Port.baseUrl}/categories'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy danh sách sản phẩm theo danh mục
  static Future<List<dynamic>> fetchProductsByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${Port.baseUrl}/products-by-category?category_id=$categoryId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Lấy chi tiết sản phẩm theo ID
  static Future<Map<String, dynamic>> getProductDetail(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('${Port.baseUrl}/products/$productId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("data cua getProductDetail_service ${data}");
        return data;
      } else {
        throw Exception('Failed to load product detail');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<ProductDetailModel> get_product_details(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('${Port.baseUrl}/products/$productId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductDetailModel.fromJson(data);
      } else {
        throw Exception('Failed to load product detail');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  //----------------Tìm kiếm sản phẩm----------------//
  static Future<List<Product>> searchProducts(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      print('ProductService - Searching for: "$query"');

      final response = await http.get(
        Uri.parse('$baseUrl/products?search=${Uri.encodeComponent(query)}'),
        headers: {'Content-Type': 'application/json'},
      );

      print('ProductService - Search response status: ${response.statusCode}');
      print('ProductService - Search response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        List<dynamic> productsData = [];

        // Xử lý nhiều format response
        if (data['data'] is List) {
          productsData = data['data'];
        } else if (data['products'] is List) {
          productsData = data['products'];
        } else if (data is List) {
          productsData = data;
        }

        print('ProductService - Found ${productsData.length} products');

        return productsData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Tìm kiếm thất bại: ${response.statusCode}');
      }
    } catch (e) {
      print('ProductService - Search error: $e');
      throw Exception('Lỗi tìm kiếm sản phẩm: $e');
    }
  }
}
