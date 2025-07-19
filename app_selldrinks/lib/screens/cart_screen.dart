import 'package:app_selldrinks/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_selldrinks/models/cart_item.dart';
import 'package:app_selldrinks/services/cart_service.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [];
  bool isLoading = true;
  String errorMessage = '';
  bool isDelivery = true;

  // Thông tin user
  int? userId;
  String userName = '';
  String userPhone = '';
  String userAddress = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final items = await CartService.getCurrentCartItems();

      setState(() {
        cartItems = items;
        isLoading = false;
      });

      print('CartScreen - Loaded ${cartItems.length} items');
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Lỗi tải giỏ hàng: $e';
      });
      print('CartScreen - Error: $e');
    }
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
      userName = prefs.getString('userName') ?? '';
      userPhone = prefs.getString('userPhone') ?? '';
      userAddress = prefs.getString('userAddress') ?? '';
    });
    print('User ID: $userId, Name: $userName, Phone: $userPhone');
  }

  String _getSizeName(int sizeId) {
    switch (sizeId) {
      case 1:
        return 'S';
      case 2:
        return 'M';
      case 3:
        return 'L';
      default:
        return 'Khác';
    }
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeItem(item);
      return;
    }

    try {
      await CartService.updateCartItemQuantity(item.id, newQuantity);
      await _loadCartItems(); // Reload cart

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật số lượng thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeItem(CartItem item) async {
    try {
      await CartService.removeCartItem(item.id);
      await _loadCartItems(); // Reload cart

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa sản phẩm'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xóa sản phẩm: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearCart() async {
    try {
      await CartService.clearCart();
      await _loadCartItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa toàn bộ giỏ hàng'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  int get totalAmount =>
      cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          'Giỏ Hàng',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _clearCart,
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: cartItems.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B2B1B)),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 16, color: Colors.red[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCartItems,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (cartItems.isEmpty) {
      return _buildEmptyCart();
    }

    return SafeArea(
      child: Column(
        children: [
          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Delivery/Pickup Options
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text(
                            'Phương Thức:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF383838),
                            ),
                          ),
                          const Spacer(),
                          _buildOptionButton('Mang Về', isDelivery, () {
                            setState(() {
                              isDelivery = true;
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildOptionButton('Tại Quán', !isDelivery, () {
                            setState(() {
                              isDelivery = false;
                            });
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Time Selection
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.access_time,
                        color: Color(0xFF383838),
                      ),
                      title: const Text(
                        'Hôm nay | Trong 15 phút',
                        style: TextStyle(color: Color(0xFF383838)),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF808080),
                      ),
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Order Notes
                  Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: const Icon(
                        Icons.note_alt_outlined,
                        color: Color(0xFF808080),
                      ),
                      title: const Text(
                        'Ghi Chú Đơn Hàng',
                        style: TextStyle(color: Color(0xFF808080)),
                      ),
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Product List Container
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Text(
                                'Danh Sách Sản Phẩm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF383838),
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Thêm Sản Phẩm',
                                  style: TextStyle(color: Color(0xFF383838)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Cart Items List
                        ...cartItems
                            .map((item) => _buildCartItem(item))
                            .toList(),

                        Divider(color: Colors.grey[300]),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Text(
                                'Tạm Tính',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF383838),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${NumberFormat('#,###', 'vi_VN').format(totalAmount)} đ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF383838),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey[300]),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Text(
                                'Khuyến Mãi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF383838),
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Thêm Khuyến Mãi',
                                  style: TextStyle(color: Color(0xFF383838)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey[300]),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Text(
                                'Tổng Cộng',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF383838),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${NumberFormat('#,###', 'vi_VN').format(totalAmount)} đ',
                                style: const TextStyle(
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B2B1B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              'Tiếp tục mua sắm',
              style: TextStyle(fontSize: 16),
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

  Widget _buildCartItem(CartItem item) {
    final numberFormat = NumberFormat('#,###', 'vi_VN');
    final sizeName = _getSizeName(item.productDetails.sizeId);

    // Lấy hình ảnh từ product nếu có, nếu không thì từ product_detail
    String imageUrl = '';
    if (item.productDetails.product?.imageUrl.isNotEmpty == true) {
      imageUrl = item.productDetails.product!.imageUrl;
    } else if (item.productDetails.img1?.isNotEmpty == true) {
      imageUrl = item.productDetails.img1!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Hình ảnh sản phẩm
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                imageUrl.isNotEmpty
                    ? Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    )
                    : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
          ),

          const SizedBox(width: 12),

          // Thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productDetails.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF383838),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: $sizeName',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF808080),
                  ),
                ),
              ],
            ),
          ),

          // Điều khiển số lượng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF383838)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _updateQuantity(item, item.quantity - 1),
                  child: const Icon(
                    Icons.remove,
                    size: 18,
                    color: Color(0xFF383838),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF383838),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _updateQuantity(item, item.quantity + 1),
                  child: const Icon(
                    Icons.add,
                    size: 18,
                    color: Color(0xFF383838),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Giá
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${numberFormat.format(item.totalPrice)} đ',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF383838),
                ),
              ),
              IconButton(
                onPressed: () => _removeItem(item),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final numberFormat = NumberFormat('#,###', 'vi_VN');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${numberFormat.format(totalAmount)}đ',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B2B1B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceedToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B2B1B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Tiến hành thanh toán',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToCheckout() {
    // TODO: Implement checkout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng thanh toán đang được phát triển'),
      ),
    );
  }
}
