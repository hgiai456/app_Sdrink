import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_selldrinks/models/product_detail.dart';

class ProductDetailService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static Future<ProductDetail?> getProductDetailIdByProductAndSize({
    required int productId,
    required int sizeId,
  }) async {
    try {
      print(
        'ProductDetailService - Input: productId=$productId, sizeId=$sizeId',
      );

      final url = Uri.parse(
        '$baseUrl/prodetail/find?pro_id=$productId&size_id=$sizeId',
      );
      print('ProductDetailService - URL: $url');

      final response = await http.get(url);
      print('ProductDetailService - Status: ${response.statusCode}');
      print('ProductDetailService - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('ProductDetailService - Decoded response: $jsonResponse');
        print(
          'ProductDetailService - Response type: ${jsonResponse.runtimeType}',
        );

        if (jsonResponse['data'] != null) {
          print('ProductDetailService - Data found: ${jsonResponse['data']}');
          return ProductDetail.fromJson(jsonResponse['data']);
        }
      }
    } catch (e, stackTrace) {
      print('Error in ProductDetailService: $e');
      print('Stack trace: $stackTrace');
    }
    return null;
  }
}
