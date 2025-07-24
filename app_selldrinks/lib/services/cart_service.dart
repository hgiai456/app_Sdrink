import 'dart:convert';
import 'package:app_selldrinks/services/port.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CartService {
  // Cache cart ID trong memory để tránh gọi API nhiều lần
  static int? _cachedCartId;
  static String? _cachedSessionId;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('CartService - _getToken result: $token');
    return token;
  }

  Future<int?> fetchCartIdBySession(String sessionId) async {
    // Nếu session không đổi và đã có cart ID cached, dùng luôn
    if (_cachedSessionId == sessionId && _cachedCartId != null) {
      print('fetchCartIdBySession - Using cached cart ID: $_cachedCartId');
      return _cachedCartId;
    }

    final token = await _getToken();
    print('fetchCartIdBySession - Token: $token');
    print('fetchCartIdBySession - Looking for session: $sessionId');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.get(
      Uri.parse('${Port.baseUrl}/carts'),
      headers: headers,
    );

    if (res.statusCode == 200) {
      final dynamic responseBody = jsonDecode(res.body);
      print('Cart API response: $responseBody');

      // Check if response is a list or object with data property
      List<dynamic> carts;
      if (responseBody is List) {
        carts = responseBody;
      } else if (responseBody is Map && responseBody.containsKey('data')) {
        if (responseBody['data'] is List) {
          carts = responseBody['data'];
        } else {
          carts = [responseBody['data']];
        }
      } else if (responseBody is Map) {
        carts = [responseBody];
      } else {
        throw Exception('Unexpected response format');
      }

      print(
        'fetchCartIdBySession - Available sessions: ${carts.map((c) => c['session_id']).toList()}',
      );

      final matchedCart = carts.firstWhere(
        (cart) => cart['session_id'] == sessionId,
        orElse: () => null,
      );

      print('fetchCartIdBySession - Matched cart: $matchedCart');

      if (matchedCart != null) {
        final cartId = matchedCart['id'];
        print('fetchCartIdBySession - Found existing cart ID: $cartId');

        // Cache kết quả
        _cachedCartId = cartId;
        _cachedSessionId = sessionId;

        return cartId;
      } else {
        // No cart found for this session, try to create a new one
        print(
          'fetchCartIdBySession - No cart found for session $sessionId, creating new cart',
        );

        try {
          final newCartId = await createCart(sessionId);
          print('fetchCartIdBySession - Created new cart with ID: $newCartId');

          // Cache cart ID mới
          _cachedCartId = newCartId;
          _cachedSessionId = sessionId;

          return newCartId;
        } catch (e) {
          // If creation fails due to conflict (409), try to fetch again
          if (e.toString().contains('409') ||
              e.toString().contains('đã tồn tại')) {
            print(
              'fetchCartIdBySession - Cart already exists (409), waiting and retrying...',
            );

            // Wait longer for database to sync
            await Future.delayed(Duration(milliseconds: 1000));

            // Try to fetch cart list again
            final retryRes = await http.get(
              Uri.parse('${Port.baseUrl}/carts'),
              headers: headers,
            );

            if (retryRes.statusCode == 200) {
              final retryResponseBody = jsonDecode(retryRes.body);
              print('Retry Cart API response: $retryResponseBody');

              List<dynamic> retryCarts;

              if (retryResponseBody is List) {
                retryCarts = retryResponseBody;
              } else if (retryResponseBody is Map &&
                  retryResponseBody.containsKey('data')) {
                if (retryResponseBody['data'] is List) {
                  retryCarts = retryResponseBody['data'];
                } else {
                  retryCarts = [retryResponseBody['data']];
                }
              } else {
                retryCarts = [retryResponseBody];
              }

              final retryMatchedCart = retryCarts.firstWhere(
                (cart) => cart['session_id'] == sessionId,
                orElse: () => null,
              );

              if (retryMatchedCart != null) {
                final cartId = retryMatchedCart['id'];
                print('fetchCartIdBySession - Found cart after retry: $cartId');

                // Cache kết quả
                _cachedCartId = cartId;
                _cachedSessionId = sessionId;

                return cartId;
              } else {
                print('fetchCartIdBySession - Still no cart found after retry');
                // Có thể cart bị delay quá lâu, thử tạo cart khác hoặc dùng fallback
                throw Exception('Không thể tìm thấy cart sau khi tạo');
              }
            }
          }

          // If still can't find or create, rethrow the error
          throw e;
        }
      }
    } else {
      print(
        'fetchCartIdBySession - Error: Status ${res.statusCode}, Body: ${res.body}',
      );
      throw Exception('Không lấy được danh sách cart');
    }
  }

  Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('session_id');
    if (sessionId == null) {
      sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      prefs.setString('session_id', sessionId);
      print('getSessionId - Created new session: $sessionId');

      // Clear cache khi tạo session mới
      _cachedCartId = null;
      _cachedSessionId = null;
    } else {
      print('getSessionId - Using existing session: $sessionId');
    }
    return sessionId;
  }

  Future<int> createCart(String sessionId) async {
    final token = await _getToken();
    print('createCart - Token: $token');
    print('createCart - Creating cart for session: $sessionId');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({'session_id': sessionId});
    print('createCart - Request URL: ${Port.baseUrl}/carts');
    print('createCart - Request headers: $headers');
    print('createCart - Request body: $body');

    final res = await http.post(
      Uri.parse('${Port.baseUrl}/carts'),
      headers: headers,
      body: body,
    );

    print('createCart - Response status: ${res.statusCode}');
    print('createCart - Response body: ${res.body}');

    if (res.statusCode == 201 || res.statusCode == 200) {
      final responseBody = jsonDecode(res.body);
      if (responseBody['data'] != null && responseBody['data']['id'] != null) {
        final cartId = responseBody['data']['id'];
        print('createCart - Created cart with ID: $cartId');
        return cartId;
      }
    }

    throw Exception(
      'Tạo giỏ hàng thất bại: Status ${res.statusCode}, Body: ${res.body}',
    );
  }

  Future<void> addToCart({
    required int productDetailId,
    required int quantity,
  }) async {
    final sessionId = await getSessionId();
    final cartId = await fetchCartIdBySession(sessionId);

    final token = await _getToken();
    print('CartService - Token: $token');
    print('CartService - Session ID: $sessionId');
    print('CartService - Cart ID: $cartId');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'cart_id': cartId,
      'product_detail_id': productDetailId,
      'quantity': quantity,
    });

    print('CartService - Request URL: ${Port.baseUrl}/cart-items');
    print('CartService - Request headers: $headers');
    print('CartService - Request body: $body');

    final res = await http.post(
      Uri.parse('${Port.baseUrl}/cart-items'),
      headers: headers,
      body: body,
    );

    print('CartService - Response status: ${res.statusCode}');
    print('CartService - Response body: ${res.body}');

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(
        'Thêm vào giỏ hàng thất bại: Status ${res.statusCode}, Body: ${res.body}',
      );
    }
  }

  // Method thanh toán giỏ hàng
  Future<Map<String, dynamic>> checkout({
    required int cartId,
    required String phone,
    required String note,
    required String address,
  }) async {
    final token = await _getToken();
    print('checkout - Token: $token');
    print('checkout - Cart ID: $cartId');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'cart_id': cartId,
      'phone': phone,
      'note': note,
      'address': address,
    });

    print('checkout - Request URL: ${Port.baseUrl}/carts/checkout');
    print('checkout - Request body: $body');

    final res = await http.post(
      Uri.parse('${Port.baseUrl}/carts/checkout'),
      headers: headers,
      body: body,
    );

    print('checkout - Response status: ${res.statusCode}');
    print('checkout - Response body: ${res.body}');

    if (res.statusCode == 200 || res.statusCode == 201) {
      final responseBody = jsonDecode(res.body);

      // Thanh toán thành công -> xóa session và cache để tạo giỏ hàng mới lần sau
      await clearSession();

      return responseBody;
    } else {
      throw Exception(
        'Thanh toán thất bại: Status ${res.statusCode}, Body: ${res.body}',
      );
    }
  }

  // Method xóa session_id sau khi thanh toán thành công
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_id');

    // Clear cache
    _cachedCartId = null;
    _cachedSessionId = null;

    print('clearSession - Session and cache cleared successfully');
  }

  // Method lấy cart ID hiện tại (để dùng cho checkout)
  Future<int?> getCurrentCartId() async {
    final sessionId = await getSessionId();
    return await fetchCartIdBySession(sessionId);
  }

  // Method lấy cart theo ID với chi tiết sản phẩm
  Future<Map<String, dynamic>?> getCartById(int cartId) async {
    final token = await _getToken();
    print('getCartById - Token: $token');
    print('getCartById - Cart ID: $cartId');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.get(
      Uri.parse('${Port.baseUrl}/carts/$cartId'),
      headers: headers,
    );

    print('getCartById - Response status: ${res.statusCode}');
    print('getCartById - Response body: ${res.body}');

    if (res.statusCode == 200) {
      final responseBody = jsonDecode(res.body);
      return responseBody;
    } else if (res.statusCode == 404) {
      // Cart không tồn tại
      print('getCartById - Cart not found, clearing cache');
      _cachedCartId = null;
      _cachedSessionId = null;
      return null;
    } else {
      throw Exception(
        'Lấy thông tin giỏ hàng thất bại: Status ${res.statusCode}, Body: ${res.body}',
      );
    }
  }

  // Method lấy cart hiện tại với chi tiết sản phẩm
  Future<Map<String, dynamic>?> getCurrentCart() async {
    final cartId = await getCurrentCartId();
    if (cartId != null) {
      return await getCartById(cartId);
    }
    return null;
  }

  // Method cập nhật số lượng sản phẩm trong giỏ
  Future<void> updateCartItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    final token = await _getToken();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({'quantity': quantity});

    final res = await http.put(
      Uri.parse('${Port.baseUrl}/cart-items/$cartItemId'),
      headers: headers,
      body: body,
    );

    print('updateCartItemQuantity - Response status: ${res.statusCode}');
    print('updateCartItemQuantity - Response body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Cập nhật số lượng thất bại');
    }
  }

  // Method xóa sản phẩm khỏi giỏ hàng
  Future<void> removeCartItem(int cartItemId) async {
    final token = await _getToken();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.delete(
      Uri.parse('${Port.baseUrl}/cart-items/$cartItemId'),
      headers: headers,
    );

    print('removeCartItem - Response status: ${res.statusCode}');

    if (res.statusCode != 200) {
      throw Exception('Xóa sản phẩm thất bại');
    }
  }
}
