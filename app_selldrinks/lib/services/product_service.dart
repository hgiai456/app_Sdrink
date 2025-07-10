import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    }
    throw Exception('Failed to load categories');
  }

  static Future<List<dynamic>> fetchProductsByCategory(int categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products-by-category?category_id=$categoryId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    }
    throw Exception('Failed to load products');
  }

  static Future<String?> fetchProductImage(int productId) async {
    // Lấy từ product_images
    final imageResponse = await http.get(
      Uri.parse('$baseUrl/product-images?product_id=$productId'),
    );
    if (imageResponse.statusCode == 200) {
      final imageData = json.decode(imageResponse.body);
      final images = imageData['data'] ?? [];
      if (images.isNotEmpty) {
        return images[0]['image_url'];
      }
    }

    // Nếu không có trong product_images, lấy từ products.image
    final productResponse = await http.get(
      Uri.parse('$baseUrl/products/$productId'),
    );
    if (productResponse.statusCode == 200) {
      final productData = json.decode(productResponse.body);
      return productData['data']['image'];
    }
    return null;
  }
}
