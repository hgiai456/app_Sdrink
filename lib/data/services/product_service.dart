import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../../core/constants/app_constants.dart';

class ProductService {
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/products/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/products/category/$category'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }
} 