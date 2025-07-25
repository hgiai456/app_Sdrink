import 'dart:convert';
import 'package:app_selldrinks/models/cart_item.dart';
import 'package:app_selldrinks/services/port.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_selldrinks/models/cart.dart';
import 'package:http/http.dart' as http;

class CartService {
  static const String baseUrl = Port.baseUrl;

  /// Lấy hoặc tạo session_id và lưu vào SharedPreferences
  static Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      print('CartService - Retrieved userId: $userId');
      return userId;
    } catch (e) {
      print('CartService - Error getting userId: $e');
      return null;
    }
  }

  //debug session
  static Future<void> debugSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final userName = prefs.getString('userName');
      final userPhone = prefs.getString('userPhone');

      print('=== DEBUG SESSION ===');
      print('UserId: $userId');
      print('UserName: $userName');
      print('UserPhone: $userPhone');
      print('=====================');

      if (userId == null) {
        print('WARNING: User not logged in!');
      }
    } catch (e) {
      print('Error in debugSession: $e');
    }
  }

  static Future<Cart?> getOrCreateCart() async {
    try {
      final userId = await getUserId();

      if (userId == null) {
        throw Exception('User not logged in');
      }

      print('CartService - Getting cart for userId: $userId');

      // Kiểm tra cart hiện có
      Cart? existingCart = await getCartByUserId(userId);

      if (existingCart != null) {
        print('CartService - Found existing cart: ${existingCart.id}');
        return existingCart;
      }

      // Tạo cart mới nếu chưa có
      print('CartService - Creating new cart for userId: $userId');
      Cart? newCart = await createCart(userId);

      return newCart;
    } catch (e) {
      print('CartService - Error in getOrCreateCart: $e');
      // Thay vì return null, thử get cart một lần nữa
      try {
        final userId = await getUserId();
        if (userId != null) {
          final cart = await getCartByUserId(userId);
          if (cart != null) {
            print('CartService - Fallback: Found existing cart after error');
            return cart;
          }
        }
      } catch (fallbackError) {
        print('CartService - Fallback also failed: $fallbackError');
      }
      return null;
    }
  }

  /// Lấy cart theo userId với xử lý lỗi tốt hơn
  static Future<Cart?> getCartByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/carts/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('getCartByUserId - Status: ${response.statusCode}');
      print('getCartByUserId - Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['data'] != null) {
          try {
            return Cart.fromJson(responseData['data']);
          } catch (parseError) {
            print('getCartByUserId - Parse error: $parseError');
            print('getCartByUserId - Raw data: ${responseData['data']}');
            return null;
          }
        }
      } else if (response.statusCode == 404) {
        print('getCartByUserId - No cart found for userId: $userId');
        return null;
      }

      return null;
    } catch (e) {
      print('getCartByUserId - Error: $e');
      return null;
    }
  }

  /// Debug method chi tiết
  static Future<void> debugCartProcess(int userId) async {
    print('=== DEBUG CART PROCESS ===');

    try {
      // Step 1: Check existing cart
      print('Step 1: Checking existing cart...');
      final existingCart = await getCartByUserId(userId);

      if (existingCart != null) {
        print(
          'Found existing cart: ID=${existingCart.id}, Items=${existingCart.cartItems.length}',
        );
        return;
      }

      print('No existing cart found');

      // Step 2: Try create new cart
      print('Step 2: Creating new cart...');
      final newCart = await createCart(userId);

      if (newCart != null) {
        print('Created new cart: ID=${newCart.id}');
      } else {
        print('Failed to create cart');
      }
    } catch (e) {
      print('Debug error: $e');
    }

    print('=== END DEBUG ===');
  }

  static Future<Cart?> createCart(int userId) async {
    try {
      // Xóa session_id cũ trước khi tạo cart mới
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_id');

      final response = await http.post(
        Uri.parse('$baseUrl/carts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      print('createCart - Status: ${response.statusCode}');
      print('createCart - Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['data'] != null) {
          return Cart.fromJson(responseData['data']);
        } else {
          return Cart.fromJson(responseData);
        }
      } else if (response.statusCode == 409) {
        // Cart đã tồn tại, return null để trigger get existing cart
        print('createCart - Cart already exists, will try to get existing');
        return null;
      }

      return null;
    } catch (e) {
      print('createCart - Error: $e');
      return null;
    }
  }

  static Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('sessionId');
      await prefs.remove('userId');
      await prefs.remove('userName');
      await prefs.remove('userPhone');
      await prefs.remove('userAddress');
      print('CartService - Session cleared');
    } catch (e) {
      print('CartService - Error clearing session: $e');
    }
  }

  // Helper method to check session ownership

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

  static Future<int?> fetchCartIdByUserId(int userId) async {
    try {
      // Sử dụng endpoint mới cho user cụ thể
      final res = await http.get(Uri.parse('$baseUrl/carts/user/$userId'));

      print('fetchCartIdByUserId - Status: ${res.statusCode}');
      print('fetchCartIdByUserId - Response body: ${res.body}');

      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);

        // API trả về object cart trực tiếp trong 'data'
        if (responseData is Map<String, dynamic> &&
            responseData['data'] != null) {
          final cartData = responseData['data'];
          final cartId = cartData['id'];

          print(
            'fetchCartIdByUserId - Found cart with ID: $cartId for userId: $userId',
          );
          return cartId;
        }

        print('fetchCartIdByUserId - Invalid data structure');
        return null;
      } else if (res.statusCode == 404) {
        print('fetchCartIdByUserId - No cart found for userId: $userId');
        return null;
      } else {
        throw Exception('API Error: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      print('fetchCartIdByUserId - Error: $e');
      return null;
    }
  }

  static Future<Cart?> getCart() async {
    try {
      final userId = await getUserId();

      if (userId == null) {
        throw Exception('User not logged in');
      }

      print('getCart - Using UserId: $userId');

      // Gọi trực tiếp API cart của user
      final response = await http.get(Uri.parse('$baseUrl/carts/user/$userId'));

      print('getCart - Status: ${response.statusCode}');
      print('getCart - Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['data'] != null) {
          return Cart.fromJson(responseData['data']);
        }
      } else if (response.statusCode == 404) {
        print('getCart - User has no cart');
        return null;
      } else {
        throw Exception('Failed to get cart: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      print('getCart - Error: $e');
      return null;
    }
  }

  // static Future<Cart> ensureCartExists() async {
  //   try {
  //     final userId = await getUserId();

  //     if (userId == null) {
  //       throw Exception('User not logged in');
  //     }

  //     print('ensureCartExists - UserId: $userId');

  //     // Bước 1: Kiểm tra cart hiện có bằng API mới
  //     final response = await http.get(Uri.parse('$baseUrl/carts/user/$userId'));

  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);
  //       if (responseData['data'] != null) {
  //         print('ensureCartExists - Found existing cart');
  //         return Cart.fromJson(responseData['data']);
  //       }
  //     } else if (response.statusCode == 404) {
  //       print('ensureCartExists - No cart found, creating new one');

  //       // Bước 2: Tạo cart mới
  //       final newCart = await createCart();
  //       if (newCart != null) {
  //         print('ensureCartExists - Successfully created cart: ${newCart.id}');
  //         return newCart;
  //       }

  //       throw Exception('Failed to create cart');
  //     } else {
  //       throw Exception('API Error: ${response.statusCode}');
  //     }

  //     throw Exception('Unable to ensure cart exists');
  //   } catch (e) {
  //     print('ensureCartExists - Error: $e');
  //     rethrow;
  //   }
  // }

  /// Lấy chi tiết giỏ hàng với tính toán tổng tiền
  static Future<Map<String, dynamic>?> getCartWithDetails() async {
    try {
      final userId = await getUserId();

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final cart = await getCartByUserId(userId);

      if (cart == null) {
        print('getCartWithDetails - No cart found');
        return null;
      }

      // Tính toán tổng tiền và số lượng
      int totalAmount = cart.totalPrice;
      int totalItems = cart.totalItems;

      print(
        'getCartWithDetails - Cart ID: ${cart.id}, Total: $totalAmount, Items: $totalItems',
      );

      return {
        'cartId': cart.id,
        'totalAmount': totalAmount,
        'totalItems': totalItems,
        'cartItems': cart.cartItems.map((item) => item.toJson()).toList(),
        'cart': cart,
      };
    } catch (e) {
      print('getCartWithDetails - Error: $e');
      return null;
    }
  }

  /// Lấy số lượng items trong giỏ hàng
  static Future<int> getCartItemCount() async {
    try {
      final cartDetails = await getCartWithDetails();
      return cartDetails?['totalItems'] ?? 0;
    } catch (e) {
      print('getCartItemCount - Error: $e');
      return 0;
    }
  }

  static Future<CartItem?> findCartItem(int productDetailId) async {
    try {
      final cart = await getOrCreateCart();

      if (cart == null) return null;

      for (CartItem item in cart.cartItems) {
        if (item.productDetailId == productDetailId) {
          return item;
        }
      }
      return null;
    } catch (e) {
      print('findCartItem - Error: $e');
      return null;
    }
  }

  static Future<Cart?> getCurrentCart() async {
    try {
      final userId = await getUserId();

      if (userId == null) {
        print('CartService - No userId found');
        return null;
      }

      print('CartService - Getting current cart for userId: $userId');

      final response = await http.get(
        Uri.parse('$baseUrl/carts/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print(
        'CartService - getCurrentCart response status: ${response.statusCode}',
      );
      print('CartService - getCurrentCart response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['data'] != null) {
          final cartData = responseData['data'];
          print('CartService - Parsing cart data: $cartData');

          try {
            final cart = Cart.fromJson(cartData);
            print(
              'CartService - Successfully parsed cart: ${cart.id} with ${cart.cartItems.length} items',
            );
            return cart;
          } catch (parseError) {
            print('CartService - Error parsing cart: $parseError');
            print('CartService - Cart data: $cartData');
            return null;
          }
        } else {
          print('CartService - No cart data in response');
          return null;
        }
      } else {
        print('CartService - Failed to get cart: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('CartService - Error in getCurrentCart: $e');
      return null;
    }
  }

  /// Migration method: Chuyển cart từ session_id sang user_id khi user login
  // static Future<void> migrateCartToUser(int userId) async {
  //   try {
  //     final sessionId = await getSessionId();
  //     print('migrateCartToUser - Migrating cart from session: $sessionId to user: $userId');

  //     // Tìm cart theo session_id
  //     final sessionCartId = await fetchCartIdBySession(sessionId);
  //     if (sessionCartId == null) {
  //       print('migrateCartToUser - No session cart to migrate');
  //       return;
  //     }

  //     // Kiểm tra xem user đã có cart chưa
  //     final userCartId = await fetchCartIdByUserId(userId);
  //     if (userCartId != null) {
  //       print('migrateCartToUser - User already has cart, merging...');
  //       // TODO: Implement merge logic if needed
  //       // For now, just use user's existing cart
  //       return;
  //     }

  //     // Update cart để gán user_id
  //     final response = await http.put(
  //       Uri.parse('$baseUrl/carts/$sessionCartId'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'user_id': userId,
  //         'session_id': null, // Clear session_id
  //       }),
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 204) {
  //       print('migrateCartToUser - Successfully migrated cart to user');

  //       // Clear session_id từ SharedPreferences
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.remove('session_id');
  //     } else {
  //       print('migrateCartToUser - Failed to migrate cart: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error in migrateCartToUser: $e');
  //   }
  // }
  // static Future<void> clearUserCart() async {
  //   try {
  //     final userId = await getUserId();
  //   } catch (e) {}
  // }

  /// Thêm sản phẩm vào giỏ hàng
  static Future<bool> addToCart({
    required int productDetailId,
    required int quantity,
  }) async {
    try {
      print(
        'CartService - Adding to cart: productDetailId=$productDetailId, quantity=$quantity',
      );

      // Lấy hoặc tạo cart
      Cart? cart = await getOrCreateCart();

      if (cart == null) {
        // Nếu không tạo được cart mới, thử lấy cart hiện có
        final userId = await getUserId();
        if (userId != null) {
          cart = await getCartByUserId(userId);
        }

        if (cart == null) {
          throw Exception('Không thể tạo hoặc lấy giỏ hàng');
        }
      }

      print('CartService - Using cart ID: ${cart.id}');

      // Kiểm tra xem sản phẩm đã có trong cart chưa
      CartItem? existingItem;
      for (CartItem item in cart.cartItems) {
        if (item.productDetailId == productDetailId) {
          existingItem = item;
          break;
        }
      }

      if (existingItem != null) {
        // Cập nhật số lượng nếu sản phẩm đã có
        print('CartService - Product exists, updating quantity');
        return await updateCartItemQuantity(
          existingItem.id,
          existingItem.quantity + quantity,
        );
      } else {
        // Thêm sản phẩm mới
        final response = await http.post(
          Uri.parse('$baseUrl/cart-items'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'cart_id': cart.id,
            'product_detail_id': productDetailId,
            'quantity': quantity,
          }),
        );

        print('addToCart - Status: ${response.statusCode}');
        print('addToCart - Response: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('CartService - Successfully added to cart');
          return true;
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Thêm vào giỏ hàng thất bại');
        }
      }
    } catch (e) {
      print('CartService - Error adding to cart: $e');
      throw Exception('Lỗi thêm vào giỏ hàng: $e');
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
  static Future<bool> clearCart() async {
    try {
      final cart = await getOrCreateCart();

      if (cart == null) {
        return true; // Nếu không có cart thì coi như đã clear
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/carts/${cart.id}'),
        headers: {'Content-Type': 'application/json'},
      );

      print('clearCart - Status: ${response.statusCode}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('clearCart - Error: $e');
      return false;
    }
  }

  /// Cập nhật số lượng sản phẩm
  static Future<bool> updateCartItemQuantity(
    int cartItemId,
    int quantity,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cart-items/$cartItemId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantity': quantity}),
      );

      print('updateCartItemQuantity - Status: ${response.statusCode}');

      return response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201;
    } catch (e) {
      print('Error updating quantity: $e');
      return false;
    }
  }

  // /// Lấy danh sách sản phẩm trong giỏ hàng với thông tin chi tiết
  // static Future<List<Map<String, dynamic>>> getCartItems() async {
  //   try {
  //     final sessionId = await getSessionId();
  //     print('getCartItems - SessionId: $sessionId');

  //     final cartId = await fetchCartIdBySession(sessionId);
  //     print('getCartItems - CartId: $cartId');

  //     if (cartId == null) {
  //       print('getCartItems - No cart found, returning empty list');
  //       return [];
  //     }

  //     // Thử các endpoint có thể để lấy cart items với thông tin sản phẩm
  //     List<String> endpoints = [
  //       '$baseUrl/cart-items/carts/$cartId/detail', // Endpoint có thông tin sản phẩm
  //       '$baseUrl/carts/$cartId/items', // Endpoint khác
  //       '$baseUrl/cart-items/carts/$cartId', // Endpoint hiện tại
  //     ];

  //     for (String endpoint in endpoints) {
  //       try {
  //         print('Trying endpoint: $endpoint');
  //         final res = await http.get(
  //           Uri.parse(endpoint),
  //           headers: {'Content-Type': 'application/json'},
  //         );

  //         print('Response status: ${res.statusCode}');
  //         print('Response body: ${res.body}');

  //         if (res.statusCode == 200) {
  //           final decoded = jsonDecode(res.body);

  //           List<Map<String, dynamic>> items = [];

  //           if (decoded is Map<String, dynamic>) {
  //             if (decoded['data'] is List) {
  //               items = List<Map<String, dynamic>>.from(decoded['data']);
  //             } else if (decoded['cart_items'] is List) {
  //               items = List<Map<String, dynamic>>.from(decoded['cart_items']);
  //             } else if (decoded['items'] is List) {
  //               items = List<Map<String, dynamic>>.from(decoded['items']);
  //             }
  //           } else if (decoded is List) {
  //             items = List<Map<String, dynamic>>.from(decoded);
  //           }

  //           if (items.isNotEmpty) {
  //             // Enriching items với thông tin sản phẩm nếu chưa có
  //             List<Map<String, dynamic>> enrichedItems = [];

  //             for (var item in items) {
  //               print('Processing item: $item');

  //               // Nếu item đã có đầy đủ thông tin sản phẩm
  //               if (item['product_detail'] != null &&
  //                   item['product_detail']['name'] != null) {
  //                 enrichedItems.add(item);
  //               } else {
  //                 // Nếu chưa có, lấy thông tin từ product_detail_id
  //                 final productDetailId = item['product_detail_id'];
  //                 if (productDetailId != null) {
  //                   final productDetail = await _getProductDetailById(
  //                     productDetailId,
  //                   );
  //                   if (productDetail != null) {
  //                     item['product_detail'] = productDetail;
  //                   }
  //                 }
  //                 enrichedItems.add(item);
  //               }
  //             }

  //             print('Found ${enrichedItems.length} enriched items');
  //             return enrichedItems;
  //           }
  //         }
  //       } catch (e) {
  //         print('Error with endpoint $endpoint: $e');
  //         continue;
  //       }
  //     }

  //     print('getCartItems - No items found');
  //     return [];
  //   } catch (e) {
  //     print('Error in getCartItems: $e');
  //     return [];
  //   }
  // }

  // /// Helper method để lấy thông tin product detail theo ID
  // static Future<Map<String, dynamic>?> _getProductDetailById(
  //   int productDetailId,
  // ) async {
  //   try {
  //     print('Getting product detail for ID: $productDetailId');

  //     final res = await http.get(
  //       Uri.parse('$baseUrl/prodetail/$productDetailId'),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     print('Product detail response: ${res.statusCode} - ${res.body}');

  //     if (res.statusCode == 200) {
  //       final decoded = jsonDecode(res.body);

  //       if (decoded is Map<String, dynamic>) {
  //         if (decoded['data'] != null) {
  //           return Map<String, dynamic>.from(decoded['data']);
  //         } else {
  //           return Map<String, dynamic>.from(decoded);
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('Error getting product detail: $e');
  //   }
  //   return null;
  // }

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
