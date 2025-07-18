import 'dart:convert';
import 'package:app_selldrinks/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_selldrinks/models/cart.dart';
import 'package:http/http.dart' as http;

class CartService {
  static const String baseUrl =
      'http://10.0.2.2:3000/api'; // Đã sửa để phù hợp với ProductService

  /// Lấy hoặc tạo session_id và lưu vào SharedPreferences

  static Future<int?> createCart(String sessionId) async {
    try {
      print('createCart - Creating cart for sessionId: $sessionId');

      final res = await http.post(
        Uri.parse('$baseUrl/carts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': sessionId}),
      );

      print('createCart - Status: ${res.statusCode}');
      print('createCart - Response: ${res.body}');

      if (res.statusCode == 201 || res.statusCode == 200) {
        final responseData = jsonDecode(res.body);

        // Nếu API trả về cart ID trong response
        if (responseData is Map && responseData['id'] != null) {
          return responseData['id'];
        }

        print('createCart - Cart created successfully');
        return null; // Sẽ được lấy trong lần gọi tiếp theo
      } else {
        print('createCart - Failed: ${res.statusCode} - ${res.body}');
        throw Exception('Tạo giỏ hàng thất bại: ${res.body}');
      }
    } catch (e) {
      print('Error in createCart: $e');
      rethrow;
    }
  }

  /// Lấy hoặc tạo session_id và lưu vào SharedPreferences
  static Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('session_id');

    if (sessionId == null) {
      sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('session_id', sessionId);
      print('getSessionId - Created NEW sessionId: "$sessionId"');
    } else {
      print('getSessionId - Using EXISTING sessionId: "$sessionId"');
    }

    print('getSessionId - SessionId details:');
    print('  Length: ${sessionId.length}');
    print('  Type: ${sessionId.runtimeType}');
    print('  Bytes: ${sessionId.codeUnits}');

    return sessionId;
  }

  static Future<int?> fetchCartIdBySession(String sessionId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/carts'));
      print('fetchCartIdBySession - Status: ${res.statusCode}');
      print('fetchCartIdBySession - Response body: ${res.body}');

      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        print('fetchCartIdBySession - Looking for sessionId: $sessionId');

        // API trả về {"message": "...", "data": [...]}
        if (responseData is Map<String, dynamic> &&
            responseData['data'] is List) {
          final carts = responseData['data'] as List;
          print('fetchCartIdBySession - Found ${carts.length} carts');

          for (var cart in carts) {
            print(
              'fetchCartIdBySession - Cart: ${cart['session_id']} (type: ${cart['session_id'].runtimeType})',
            );

            // So sánh cả String và dynamic
            if (cart['session_id'].toString() == sessionId.toString()) {
              print(
                'fetchCartIdBySession - Found matching cart with ID: ${cart['id']}',
              );
              return cart['id'];
            }
          }

          print(
            'fetchCartIdBySession - No matching cart found for sessionId: $sessionId',
          );
          return null;
        }

        throw Exception('Cấu trúc dữ liệu carts không hợp lệ');
      } else {
        throw Exception('Không lấy được danh sách carts: ${res.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error in fetchCartIdBySession: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Thêm sản phẩm vào giỏ hàng
  static Future<void> addToCart({
    required int productDetailId,
    required int quantity,
  }) async {
    try {
      print(
        'CartService - Input: productDetailId=$productDetailId, quantity=$quantity',
      );

      final sessionId = await getSessionId();
      print('CartService - SessionId: $sessionId');

      // Sử dụng hàm mới để đảm bảo cart tồn tại
      final cartId = await ensureCartExists(sessionId);
      print('CartService - CartId: $cartId');

      final requestBody = {
        'cart_id': cartId,
        'product_detail_id': productDetailId,
        'quantity': quantity,
      };
      print('CartService - Request body: $requestBody');

      final res = await http.post(
        Uri.parse('$baseUrl/cart-items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('CartService - Response status: ${res.statusCode}');
      print('CartService - Response body: ${res.body}');

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('Thêm vào giỏ hàng thất bại: ${res.body}');
      }
    } catch (e, stackTrace) {
      print('Error in CartService.addToCart: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Tạo cart mới hoặc lấy cart hiện có
  static Future<int> ensureCartExists(String sessionId) async {
    try {
      // Thử tìm cart hiện có trước
      int? cartId = await fetchCartIdBySession(sessionId);

      if (cartId != null) {
        print('ensureCartExists - Found existing cart: $cartId');
        return cartId;
      }

      // Nếu không có, thử tạo mới
      print('ensureCartExists - Creating new cart for sessionId: $sessionId');

      final res = await http.post(
        Uri.parse('$baseUrl/carts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': sessionId}),
      );

      print(
        'ensureCartExists - Create response: ${res.statusCode} - ${res.body}',
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final responseData = jsonDecode(res.body);

        // Nếu API trả về cart ID trực tiếp
        if (responseData is Map && responseData['id'] != null) {
          return responseData['id'];
        }

        // Nếu không, thử lấy lại từ danh sách
        cartId = await fetchCartIdBySession(sessionId);
        if (cartId != null) {
          return cartId;
        }

        throw Exception('Không thể lấy cart ID sau khi tạo');
      } else if (res.statusCode == 409 || res.statusCode == 400) {
        // Xử lý cả 409 (Conflict) và 400 (Bad Request)
        final responseBody = res.body.toLowerCase();
        if (responseBody.contains('session') &&
            responseBody.contains('tồn tại')) {
          // Cart đã tồn tại, thử lấy lại nhiều lần
          print('ensureCartExists - Cart already exists, fetching again');

          // Thử lấy lại với delay
          for (int i = 0; i < 3; i++) {
            await Future.delayed(Duration(milliseconds: 100 * (i + 1)));
            cartId = await fetchCartIdBySession(sessionId);

            if (cartId != null) {
              print(
                'ensureCartExists - Found cart on attempt ${i + 1}: $cartId',
              );
              return cartId;
            }
          }

          throw Exception(
            'Cart tồn tại nhưng không thể tìm thấy sau 3 lần thử',
          );
        } else {
          throw Exception('Tạo giỏ hàng thất bại: ${res.body}');
        }
      } else {
        throw Exception('Tạo giỏ hàng thất bại: ${res.body}');
      }
    } catch (e) {
      print('Error in ensureCartExists: $e');
      rethrow;
    }
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  static Future<void> removeCartItem(int cartItemId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/cart-items/$cartItemId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Xóa sản phẩm thất bại');
    }
  }

  /// Xóa toàn bộ giỏ hàng
  static Future<void> clearCart() async {
    final sessionId = await getSessionId();
    final cartId = await fetchCartIdBySession(sessionId);

    if (cartId == null) throw Exception("Không tìm thấy cart");

    final res = await http.delete(
      Uri.parse('$baseUrl/cart-items/carts/$cartId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Xóa giỏ hàng thất bại');
    }
  }

  /// Lấy danh sách sản phẩm trong giỏ hàng với thông tin chi tiết
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      final sessionId = await getSessionId();
      print('getCartItems - SessionId: $sessionId');

      final cartId = await fetchCartIdBySession(sessionId);
      print('getCartItems - CartId: $cartId');

      if (cartId == null) {
        print('getCartItems - No cart found, returning empty list');
        return [];
      }

      // Thử các endpoint có thể để lấy cart items với thông tin sản phẩm
      List<String> endpoints = [
        '$baseUrl/cart-items/carts/$cartId/detail', // Endpoint có thông tin sản phẩm
        '$baseUrl/carts/$cartId/items', // Endpoint khác
        '$baseUrl/cart-items/carts/$cartId', // Endpoint hiện tại
      ];

      for (String endpoint in endpoints) {
        try {
          print('Trying endpoint: $endpoint');
          final res = await http.get(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
          );

          print('Response status: ${res.statusCode}');
          print('Response body: ${res.body}');

          if (res.statusCode == 200) {
            final decoded = jsonDecode(res.body);

            List<Map<String, dynamic>> items = [];

            if (decoded is Map<String, dynamic>) {
              if (decoded['data'] is List) {
                items = List<Map<String, dynamic>>.from(decoded['data']);
              } else if (decoded['cart_items'] is List) {
                items = List<Map<String, dynamic>>.from(decoded['cart_items']);
              } else if (decoded['items'] is List) {
                items = List<Map<String, dynamic>>.from(decoded['items']);
              }
            } else if (decoded is List) {
              items = List<Map<String, dynamic>>.from(decoded);
            }

            if (items.isNotEmpty) {
              // Enriching items với thông tin sản phẩm nếu chưa có
              List<Map<String, dynamic>> enrichedItems = [];

              for (var item in items) {
                print('Processing item: $item');

                // Nếu item đã có đầy đủ thông tin sản phẩm
                if (item['product_detail'] != null &&
                    item['product_detail']['name'] != null) {
                  enrichedItems.add(item);
                } else {
                  // Nếu chưa có, lấy thông tin từ product_detail_id
                  final productDetailId = item['product_detail_id'];
                  if (productDetailId != null) {
                    final productDetail = await _getProductDetailById(
                      productDetailId,
                    );
                    if (productDetail != null) {
                      item['product_detail'] = productDetail;
                    }
                  }
                  enrichedItems.add(item);
                }
              }

              print('Found ${enrichedItems.length} enriched items');
              return enrichedItems;
            }
          }
        } catch (e) {
          print('Error with endpoint $endpoint: $e');
          continue;
        }
      }

      print('getCartItems - No items found');
      return [];
    } catch (e) {
      print('Error in getCartItems: $e');
      return [];
    }
  }

  /// Helper method để lấy thông tin product detail theo ID
  static Future<Map<String, dynamic>?> _getProductDetailById(
    int productDetailId,
  ) async {
    try {
      print('Getting product detail for ID: $productDetailId');

      final res = await http.get(
        Uri.parse('$baseUrl/prodetail/$productDetailId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Product detail response: ${res.statusCode} - ${res.body}');

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);

        if (decoded is Map<String, dynamic>) {
          if (decoded['data'] != null) {
            return Map<String, dynamic>.from(decoded['data']);
          } else {
            return Map<String, dynamic>.from(decoded);
          }
        }
      }
    } catch (e) {
      print('Error getting product detail: $e');
    }
    return null;
  }

  static Future<void> updateCartItemQuantity(
    int cartItemId,
    int quantity,
  ) async {
    try {
      print(
        'updateCartItemQuantity - ItemId: $cartItemId, Quantity: $quantity',
      );

      final res = await http.put(
        Uri.parse('$baseUrl/cart-items/$cartItemId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantity': quantity}),
      );

      print(
        'updateCartItemQuantity - Response: ${res.statusCode} - ${res.body}',
      );

      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Cập nhật số lượng thất bại: ${res.body}');
      }
    } catch (e) {
      print('Error in updateCartItemQuantity: $e');
      rethrow;
    }
  }

  /// Thanh toán giỏ hàng
  static Future<void> checkoutCart({
    required String phone,
    required String address,
    String note = '',
  }) async {
    final sessionId = await getSessionId();
    final cartId = await fetchCartIdBySession(sessionId);

    if (cartId == null) {
      throw Exception('Không tìm thấy cart');
    }

    final res = await http.post(
      Uri.parse('$baseUrl/carts/checkout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'cart_id': cartId,
        'phone': phone,
        'note': note,
        'address': address,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      // Sau khi thanh toán xong thì xóa session_id để tạo cart mới lần sau
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_id');
    } else {
      throw Exception('Thanh toán thất bại');
    }
  }
}
