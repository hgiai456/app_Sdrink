import 'dart:convert';
import 'package:app_selldrinks/models/cart_item.dart';
import 'package:app_selldrinks/services/port.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_selldrinks/models/cart.dart';
import 'package:http/http.dart' as http;

class CartService {
  static const String baseUrl =
      Port.baseUrl; // Đã sửa để phù hợp với ProductService

  /// Lấy hoặc tạo session_id và lưu vào SharedPreferences

  /// Tạo Cart mới
  static Future<Cart?> createCart() async {
    try {
      final sessionId = await getSessionId();
      print('createCart - SessionId: $sessionId');

      final response = await http.post(
        Uri.parse('$baseUrl/carts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': sessionId}),
      );

      print('createCart - Status: ${response.statusCode}');
      print('createCart - Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('createCart - Data: $data');

        // Kiểm tra nhiều format response có thể
        int? cartId;

        if (data is Map<String, dynamic>) {
          // Format 1: {id: 123, ...}
          if (data['id'] != null) {
            cartId = data['id'];
          }
          // Format 2: {data: {id: 123, ...}}
          else if (data['data'] != null && data['data']['id'] != null) {
            cartId = data['data']['id'];
          }
          // Format 3: {cart_id: 123}
          else if (data['cart_id'] != null) {
            cartId = data['cart_id'];
          }
        }

        if (cartId != null) {
          print('createCart - Found CartId: $cartId');
          return await getCartById(cartId);
        } else {
          print(
            'createCart - No cart ID in response, trying to fetch by session',
          );
          // Delay một chút rồi thử tìm cart theo session
          await Future.delayed(Duration(milliseconds: 500));

          // Thử tìm cart vừa tạo theo sessionId
          final fetchedCartId = await fetchCartIdBySession(sessionId);
          if (fetchedCartId != null) {
            return await getCartById(fetchedCartId);
          }
        }
      }

      print('createCart - Failed to create cart');
      return null;
    } catch (e) {
      print('createCart - Error: $e');
      return null;
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
    return sessionId;
  }

  /// Lấy Cart theo ID với đầy đủ thông tin
  static Future<Cart?> getCartById(int cartId) async {
    //Lấy cart với cart_id
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/carts/$cartId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cart.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error getting cart by ID: $e');
      return null;
    }
  }

  static Future<Cart?> getCart() async {
    try {
      final sessionId = await getSessionId();
      print('getCart - SessionId: $sessionId');

      final response = await http.get(
        Uri.parse('$baseUrl/carts'),
        headers: {'Content-Type': 'application/json'},
      );

      print('getCart - Status: ${response.statusCode}');
      print('getCart - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final carts = data['data'] as List;

        print('getCart - Found ${carts.length} carts');

        for (var cartJson in carts) {
          print('getCart - Cart sessionId: ${cartJson['session_id']}');
          if (cartJson['session_id'] == sessionId) {
            print('getCart - Found matching cart: ${cartJson['id']}');
            return await getCartById(cartJson['id']);
          }
        }

        print('getCart - No matching cart found');
      }
      return null;
    } catch (e) {
      print('getCart - Error: $e');
      return null;
    }
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

  static Future<Cart> ensureCartExists() async {
    try {
      // Kiểm tra cart hiện có trước
      Cart? cart = await getCart();
      if (cart != null) {
        print('ensureCartExists - Found existing cart: ${cart.id}');
        return cart;
      }

      print('ensureCartExists - No cart found, creating new one');

      // Thử tạo cart với retry logic
      for (int i = 0; i < 3; i++) {
        print('ensureCartExists - Attempt ${i + 1}');

        try {
          cart = await createCart();
          if (cart != null) {
            print('ensureCartExists - Created cart: ${cart.id}');
            return cart;
          }

          // Delay tăng dần
          await Future.delayed(Duration(milliseconds: 1000 * (i + 1)));

          // Thử tìm lại cart sau mỗi lần tạo failed
          cart = await getCart();
          if (cart != null) {
            print('ensureCartExists - Found cart on retry: ${cart.id}');
            return cart;
          }
        } catch (e) {
          print('ensureCartExists - Attempt ${i + 1} failed: $e');
          if (i == 2) {
            print('ensureCartExists - All attempts failed');
            rethrow;
          }
        }
      }

      throw Exception('Không thể tạo giỏ hàng sau 3 lần thử');
    } catch (e) {
      print('Error in ensureCartExists: $e');
      throw Exception('Lỗi hệ thống: $e');
    }
  }

  /// Thêm sản phẩm vào giỏ hàng
  static Future<void> addToCart({
    required int productDetailId,
    required int quantity,
  }) async {
    try {
      final cart = await ensureCartExists();
      final response = await http.post(
        Uri.parse('$baseUrl/cart-items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cart_id': cart.id,
          'product_detail_id': productDetailId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Thêm vào giỏ hàng thất bại: ${response.body}');
      }
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  /// Xóa sản phẩm khỏi giỏ hàng
  static Future<void> removeCartItem(int cartItemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart-items/$cartItemId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Xóa sản phẩm thất bại');
      }
    } catch (e) {
      print('Error removing cart item: $e');
      rethrow;
    }
  }

  /// Xóa toàn bộ giỏ hàng
  static Future<void> clearCart() async {
    //Chưa có API
    try {
      final cart = await getCart();
      if (cart == null) return;

      final response = await http.delete(
        Uri.parse('$baseUrl/cart-items/carts/${cart.id}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Xóa giỏ hàng thất bại');
      }
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
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

  /// Cập nhật số lượng sản phẩm
  static Future<void> updateCartItemQuantity(
    int cartItemId,
    int quantity,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cart-items/$cartItemId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Cập nhật số lượng thất bại: ${response.body}');
      }
    } catch (e) {
      print('Error updating quantity: $e');
      rethrow;
    }
  }

  /// Thanh toán giỏ hàng
  static Future<Map<String, dynamic>> checkoutCart({
    required String phone,
    required String address,
    String note = '',
  }) async {
    try {
      final cart = await getCart();
      if (cart == null) {
        throw Exception('Không tìm thấy giỏ hàng');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/carts/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cart_id': cart.id,
          'phone': phone,
          'note': note,
          'address': address,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Xóa session_id để tạo cart mới lần sau
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('session_id');

        return jsonDecode(response.body);
      } else {
        throw Exception('Thanh toán thất bại: ${response.body}');
      }
    } catch (e) {
      print('Error in checkout: $e');
      rethrow;
    }
  }
  // ...existing code...

  /// Lấy danh sách cart items theo cart_id
  static Future<List<CartItem>> getCartItemsByCartId(int cartId) async {
    try {
      print('getCartItemsByCartId - CartId: $cartId');

      final response = await http.get(
        Uri.parse('$baseUrl/cart-items/carts/$cartId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('getCartItemsByCartId - Status: ${response.statusCode}');
      print('getCartItemsByCartId - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> itemsData = [];

        // Xử lý nhiều format response
        if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            itemsData = data['data'];
          } else if (data['cart_items'] is List) {
            itemsData = data['cart_items'];
          } else if (data['items'] is List) {
            itemsData = data['items'];
          }
        } else if (data is List) {
          itemsData = data;
        }

        print('getCartItemsByCartId - Found ${itemsData.length} items');

        // Parse từng item
        List<CartItem> cartItems = [];
        for (var itemJson in itemsData) {
          try {
            print('Parsing cart item: $itemJson');
            final cartItem = CartItem.fromJson(itemJson);
            cartItems.add(cartItem);
            print('Successfully parsed cart item: ${cartItem.id}');
          } catch (e) {
            print('Error parsing cart item: $e');
            print('Item data: $itemJson');
          }
        }

        return cartItems;
      } else {
        throw Exception('Failed to load cart items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting cart items by cart ID: $e');
      throw Exception('Lỗi lấy danh sách sản phẩm: $e');
    }
  }

  /// Lấy cart items hiện tại với thông tin đầy đủ
  static Future<List<CartItem>> getCurrentCartItems() async {
    try {
      final cart = await getCart();
      if (cart == null) {
        return [];
      }

      return await getCartItemsByCartId(cart.id);
    } catch (e) {
      print('Error getting current cart items: $e');
      return [];
    }
  }

  // ...existing code...
}
