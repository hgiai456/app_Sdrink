import 'dart:convert';
import 'package:app_selldrinks/services/port.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CartService {
  // Cache cart ID trong memory để tránh gọi API nhiều lần
  static int? _cachedCartId;
  static String? _cachedSessionId;
  static int? _cachedUserId; // Thêm cache cho user ID

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('CartService - _getToken result: $token');
    return token;
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    print('CartService - _getUserId result: $userId');
    return userId;
  }

  Future<int?> fetchCartIdBySession(String sessionId) async {
    final currentUserId = await _getUserId();

    // Nếu session không đổi, user không đổi và đã có cart ID cached, dùng luôn
    if (_cachedSessionId == sessionId &&
        _cachedUserId == currentUserId &&
        _cachedCartId != null) {
      print('fetchCartIdBySession - Using cached cart ID: $_cachedCartId');
      return _cachedCartId;
    }

    final token = await _getToken();
    print('fetchCartIdBySession - Token: $token');
    print('fetchCartIdBySession - Looking for session: $sessionId');
    print('fetchCartIdBySession - Current user ID: $currentUserId');

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

      // Tìm cart theo session_id (chỉ dùng session_id)
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
        _cachedUserId = currentUserId;

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
          _cachedUserId = currentUserId;

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
                _cachedUserId = currentUserId;

                return cartId;
              } else {
                print('fetchCartIdBySession - Still no cart found after retry');
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
    final currentUserId = await _getUserId();

    // Tạo session key theo user để mỗi user có session riêng
    final sessionKey =
        currentUserId != null ? 'session_id_$currentUserId' : 'session_id';

    String? sessionId = prefs.getString(sessionKey);
    if (sessionId == null) {
      sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      prefs.setString(sessionKey, sessionId);
      print(
        'getSessionId - Created new session for user $currentUserId: $sessionId',
      );

      // Clear cache khi tạo session mới
      _cachedCartId = null;
      _cachedSessionId = null;
      _cachedUserId = null;
    } else {
      print(
        'getSessionId - Using existing session for user $currentUserId: $sessionId',
      );
    }
    return sessionId;
  }

  Future<int> createCart(String sessionId) async {
    final token = await _getToken();
    final userId = await _getUserId();

    print('createCart - Token: $token');
    print('createCart - Creating cart for session: $sessionId, user: $userId');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // CHỈ GỬI session_id, KHÔNG gửi user_id
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

  // Method xóa session_id theo user khi đăng xuất
  Future<void> clearSessionForUser({int? specificUserId}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = specificUserId ?? await _getUserId();

    if (userId != null) {
      final sessionKey = 'session_id_$userId';
      await prefs.remove(sessionKey);
      print('clearSessionForUser - Cleared session for user $userId');
    } else {
      // Clear generic session nếu không có user ID
      await prefs.remove('session_id');
      print('clearSessionForUser - Cleared generic session');
    }

    // Clear cache
    _cachedCartId = null;
    _cachedSessionId = null;
    _cachedUserId = null;

    print('clearSessionForUser - Session and cache cleared successfully');
  }

  // Method xóa session_id sau khi thanh toán thành công (giữ nguyên)
  Future<void> clearSession() async {
    await clearSessionForUser();
  }

  // Method xóa tất cả sessions (dùng khi cần thiết)
  Future<void> clearAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    // Xóa tất cả session keys
    for (final key in keys) {
      if (key.startsWith('session_id')) {
        await prefs.remove(key);
        print('clearAllSessions - Removed session: $key');
      }
    }

    // Clear cache
    _cachedCartId = null;
    _cachedSessionId = null;
    _cachedUserId = null;

    print('clearAllSessions - All sessions cleared');
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

      // Thanh toán thành công -> xóa session của user hiện tại
      await clearSessionForUser();

      return responseBody;
    } else {
      throw Exception(
        'Thanh toán thất bại: Status ${res.statusCode}, Body: ${res.body}',
      );
    }
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
      _cachedUserId = null;
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
