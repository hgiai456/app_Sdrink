import 'dart:convert';
import 'package:app_selldrinks/services/port.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CartService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('CartService - _getToken result: $token'); // Debug token retrieval
    return token;
  }

  Future<int?> fetchCartIdBySession(String sessionId) async {
    final token = await _getToken();
    print('fetchCartIdBySession - Token: $token'); // Debug token
    print(
      'fetchCartIdBySession - Looking for session: $sessionId',
    ); // Debug session ID

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
          // If data is a single cart object, wrap it in a list
          carts = [responseBody['data']];
        }
      } else if (responseBody is Map) {
        // If responseBody is a single cart object, wrap it in a list
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
        print('fetchCartIdBySession - Returning existing cart ID: $cartId');
        return cartId;
      } else {
        // No cart found for this session, create a new one
        print(
          'fetchCartIdBySession - No cart found for session $sessionId, creating new cart',
        );
        final newCartId = await createCart(sessionId);
        print('fetchCartIdBySession - Created new cart with ID: $newCartId');
        return newCartId;
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
    } else {
      print('getSessionId - Using existing session: $sessionId');
    }
    return sessionId;
  }

  Future<int> createCart(String sessionId) async {
    final token = await _getToken();
    print('createCart - Token: $token'); // Debug token
    print(
      'createCart - Creating cart for session: $sessionId',
    ); // Debug session

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
    print('CartService - Token: $token'); // Debug token
    print('CartService - Session ID: $sessionId'); // Debug session ID
    print('CartService - Cart ID: $cartId'); // Debug cart ID

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

    // Sau khi thêm thành công, kiểm tra và hiển thị thông tin
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

      // Thanh toán thành công -> xóa session để tạo giỏ hàng mới lần sau
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
    print('clearSession - Session cleared successfully');
  }

  // Method lấy cart ID hiện tại (để dùng cho checkout)
  Future<int?> getCurrentCartId() async {
    final sessionId = await getSessionId();
    return await fetchCartIdBySession(sessionId);
  }
}
