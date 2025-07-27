import 'package:app_selldrinks/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_selldrinks/models/cart_item.dart';
import 'package:app_selldrinks/services/cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:app_selldrinks/screens/order_confirm_screen.dart'; // Thêm import này

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isDelivery = true;
  bool isLoading = true;
  bool isCheckingOut = false;

  // Dữ liệu từ API
  List<CartItem> cartItems = [];
  Map<String, dynamic>? cartData;
  int? currentCartId;

  // Thông tin user
  int? userId;
  String userName = '';
  String userPhone = '';
  String userAddress = '';

  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCartData();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
      userName = prefs.getString('userName') ?? '';
      userPhone = prefs.getString('userPhone') ?? '';
      userAddress = prefs.getString('userAddress') ?? '';
    });
    print('User Info - ID: $userId, Name: $userName, Phone: $userPhone');
  }

  Future<void> _loadCartData() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Lấy cart ID hiện tại
      currentCartId = await _cartService.getCurrentCartId();
      print('Current Cart ID: $currentCartId');

      if (currentCartId != null) {
        // Lấy chi tiết giỏ hàng
        cartData = await _cartService.getCartById(currentCartId!);
        print('Cart Data: $cartData');

        if (cartData != null && cartData!['data'] != null) {
          final data = cartData!['data'];

          // Parse cart items
          if (data['cart_items'] != null) {
            cartItems =
                (data['cart_items'] as List)
                    .map((item) => CartItem.fromJson(item))
                    .toList();
          }
        }
      }
    } catch (e) {
      print('Error loading cart data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải giỏ hàng: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Tính tổng tiền - SỬA LẠI ĐỂ DÙNG ĐÚNG PRODETAIL
  int get totalAmount {
    if (cartItems.isEmpty) return 0;

    return cartItems.fold(0, (total, item) {
      // Sử dụng productPrice từ CartItem model đã sửa
      return total + (item.productPrice * item.quantity);
    });
  }

  // Cập nhật số lượng sản phẩm
  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeItem(item);
      return;
    }

    try {
      await _cartService.updateCartItemQuantity(
        cartItemId: item.id,
        quantity: newQuantity,
      );

      // Reload cart data
      await _loadCartData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật số lượng thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  // Xóa sản phẩm khỏi giỏ
  Future<void> _removeItem(CartItem item) async {
    try {
      await _cartService.removeCartItem(item.id);

      // Reload cart data
      await _loadCartData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa sản phẩm khỏi giỏ hàng')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  // Xóa toàn bộ giỏ hàng
  Future<void> _clearCart() async {
    if (cartItems.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa toàn bộ giỏ hàng?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        // Xóa từng item
        for (final item in cartItems) {
          await _cartService.removeCartItem(item.id);
        }

        // Reload cart
        await _loadCartData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa toàn bộ giỏ hàng')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  // Thanh toán - CẬP NHẬT
  Future<void> _handleCheckout() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giỏ hàng trống')));
      return;
    }

    // Chuyển đến màn hình xác nhận thông tin thay vì checkout trực tiếp
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderConfirmScreen(
              cartId: currentCartId!,
              totalAmount: totalAmount,
              defaultName: userName,
              defaultPhone: userPhone,
              defaultAddress: userAddress,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF383838),
          title: const Text('Giỏ Hàng', style: TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF383838),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
        ),
        title: Text(
          'Giỏ Hàng (${cartItems.length} sản phẩm)',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: cartItems.isNotEmpty ? _clearCart : null,
            child: Text(
              'Xóa Giỏ Hàng',
              style: TextStyle(
                color: cartItems.isNotEmpty ? Colors.white : Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Giỏ hàng trống',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                ),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF383838)),
            child: const Text(
              'Tiếp tục mua sắm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        // Main scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Delivery/Pickup Options
                _buildDeliveryOptions(),
                const SizedBox(height: 16),
                // Order Notes
                _buildOrderNotes(),
                const SizedBox(height: 16),
                // Product List
                _buildProductList(),
              ],
            ),
          ),
        ),
        // Fixed bottom bar
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildDeliveryOptions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              'Phương Thức:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF383838),
              ),
            ),
            Spacer(),
            _buildOptionButton('Mang Về', isDelivery, () {
              setState(() {
                isDelivery = true;
              });
            }),
            SizedBox(width: 8),
            _buildOptionButton('Tại Quán', !isDelivery, () {
              setState(() {
                isDelivery = false;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNotes() {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(Icons.note_alt_outlined, color: Color(0xFF808080)),
        title: Text(
          'Ghi Chú Đơn Hàng',
          style: TextStyle(color: Color(0xFF808080)),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Danh Sách Sản Phẩm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF383838),
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed:
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      ),
                  child: Text(
                    'Thêm Sản Phẩm',
                    style: TextStyle(color: Color(0xFF383838)),
                  ),
                ),
              ],
            ),
          ),
          // Cart Items
          ...cartItems.map((item) => _buildProductItem(item)).toList(),

          Divider(color: Color(0xFF808080)),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Tạm Tính',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF383838),
                  ),
                ),
                Spacer(),
                Text(
                  NumberFormat('#,### đ').format(totalAmount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF383838),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Color(0xFF808080)),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Khuyến Mãi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF383838),
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Thêm Khuyến Mãi',
                    style: TextStyle(color: Color(0xFF383838)),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Color(0xFF808080)),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Tổng Cộng',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF383838),
                  ),
                ),
                Spacer(),
                Text(
                  NumberFormat('#,### đ').format(totalAmount),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF383838),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(CartItem item) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                item.productImage.isNotEmpty
                    ? Image.network(
                      item.productImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: Icon(Icons.image, color: Colors.grey),
                          ),
                    )
                    : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, color: Colors.grey),
                    ),
          ),
          SizedBox(width: 12),

          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên sản phẩm (không có size)
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF383838),
                  ),
                ),
                SizedBox(height: 4),

                // Tên chi tiết với size
                Text(
                  item.productDetailName,
                  style: TextStyle(fontSize: 14, color: Color(0xFF808080)),
                ),
                SizedBox(height: 4),

                // Thông số kỹ thuật
                if (item.specification.isNotEmpty)
                  Text(
                    item.specification,
                    style: TextStyle(fontSize: 12, color: Color(0xFF808080)),
                  ),
                SizedBox(height: 8),

                // Giá tiền
                Row(
                  children: [
                    Text(
                      NumberFormat('#,### đ').format(item.productPrice),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF383838),
                      ),
                    ),
                    if (item.oldPrice > item.productPrice) ...[
                      SizedBox(width: 8),
                      Text(
                        NumberFormat('#,### đ').format(item.oldPrice),
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF808080),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Điều khiển số lượng và xóa
          Column(
            children: [
              // Điều khiển số lượng
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF383838).withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Color(0xFF383838)),
                      onPressed: () => _updateQuantity(item, item.quantity - 1),
                      iconSize: 18,
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        item.quantity.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF383838),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Color(0xFF383838)),
                      onPressed: () => _updateQuantity(item, item.quantity + 1),
                      iconSize: 18,
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),

              // Tổng giá cho item này
              Text(
                NumberFormat(
                  '#,### đ',
                ).format(item.productPrice * item.quantity),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF383838),
                ),
              ),
              SizedBox(height: 4),

              // Nút xóa
              TextButton(
                onPressed: () => _removeItem(item),
                child: Text(
                  'Xóa',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Row(
        children: [
          // Payment options
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF383838)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.credit_card, color: Color(0xFF383838), size: 16),
                SizedBox(width: 4),
                Text(
                  'Thẻ Nội Địa',
                  style: TextStyle(color: Color(0xFF383838), fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          // Order button
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed:
                    cartItems.isNotEmpty && !isCheckingOut
                        ? _handleCheckout
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF383838),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    isCheckingOut
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          'ĐẶT HÀNG (${NumberFormat('#,### đ').format(totalAmount)})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF383838) : Colors.white,
          border: Border.all(
            color: Color(0xFF383838).withOpacity(isSelected ? 1 : 0.3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF383838),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
