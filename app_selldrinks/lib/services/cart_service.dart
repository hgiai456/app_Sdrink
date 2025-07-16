import 'dart:convert';
import 'package:app_selldrinks/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_selldrinks/models/cart.dart';
import 'package:http/http.dart' as http;

Future<int?> fetchCartIdBySession(String sessionId) async {
  final res = await http.get(Uri.parse('http://localhost:3000/api/carts'));

  if (res.statusCode == 200) {
    final List<dynamic> carts = jsonDecode(res.body);
    final matchedCart = carts.firstWhere(
      (cart) => cart['session_id'] == sessionId,
      orElse: () => null,
    );

    return matchedCart != null ? matchedCart['id'] : null;
  } else {
    throw Exception('Không lấy được danh sách cart');
  }
}

Future<String> getSessionId() async {
  final prefs = await SharedPreferences.getInstance();
  String? sessionId = prefs.getString('session_id');
  if (sessionId == null) {
    sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    prefs.setString('session_id', sessionId);
    await createCart(sessionId);
  }
  return sessionId;
}

Future<void> createCart(String sessionId) async {
  final res = await http.post(
    Uri.parse('http://localhost:3000/api/carts'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'session_id': sessionId}),
  );

  if (res.statusCode != 201 && res.statusCode != 200) {
    throw Exception('Tạo giỏ hàng thất bại');
  }
}

Future<void> addToCart({
  required int productDetailId,
  required int quantity,
}) async {
  final sessionId = await getSessionId();
  final cartId = await fetchCartIdBySession(sessionId);

  final res = await http.post(
    Uri.parse('http://localhost:3000/api/cart-items'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'cart_id': cartId,
      'product_detail_id': productDetailId,
      'quantity': quantity,
    }),
  );

  if (res.statusCode != 200 && res.statusCode != 201) {
    throw Exception('Thêm vào giỏ hàng thất bại');
  }
}
