import 'package:app_selldrinks/screens/checkout_screen.dart';
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
  int? cartId;
  int? totalAmount;

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

      // Lấy cart hiện tại
      final cart = await CartService.getCurrentCart();

      if (cart != null) {
        setState(() {
          cartId = cart.id;
          totalAmount = cart.totalPrice;
          cartItems = cart.cartItems;
        });

        print(
          'CartScreen - Loaded cart: ID=$cartId, Items=${cartItems.length}, Total=$totalAmount',
        );
      } else {
        setState(() {
          cartId = null;
          cartItems = [];
          totalAmount = 0;
        });
        print('CartScreen - No cart found');
      }
    } catch (e) {
      print('CartScreen - Error loading cart: $e');
      setState(() {
        cartId = null;
        cartItems = [];
        totalAmount = 0;
        errorMessage = 'Lỗi tải giỏ hàng: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
      await _loadCartItems();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cập nhật số lượng thành công',
            style: Theme.of(context).textTheme.labelLarge,
          ),
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
      await _loadCartItems();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã xóa sản phẩm',
            style: Theme.of(context).textTheme.labelLarge,
          ),
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
        SnackBar(
          content: Text(
            'Đã xóa toàn bộ giỏ hàng',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  int get totalAmount1 =>
      cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // kLightGray
      appBar: AppBar(
        backgroundColor: kDarkGray, // Custom dark for cart
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kWhite),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
        ),
        title: Text(
          'Giỏ Hàng',
          style: theme.textTheme.titleMedium?.copyWith(
            color: kWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: kWhite),
              onPressed: _clearCart,
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: cartItems.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
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
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Delivery/Pickup Options
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
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
                          Text(
                            'Phương Thức:',
                            style: theme.textTheme.titleMedium,
                          ),
                          const Spacer(),
                          _buildOptionButton('Mang Về', isDelivery, () {
                            setState(() => isDelivery = true);
                          }),
                          const SizedBox(width: 8),
                          _buildOptionButton('Tại Quán', !isDelivery, () {
                            setState(() => isDelivery = false);
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Product List Container
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
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
                              Text(
                                'Danh Sách Sản Phẩm',
                                style: theme.textTheme.titleMedium,
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Thêm Sản Phẩm',
                                  style: theme.textTheme.labelMedium,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Cart Items List
                        ...cartItems
                            .map((item) => _buildCartItem(item))
                            .toList(),

                        Divider(color: theme.dividerColor),

                        // Tạm Tính
                        Divider(color: theme.dividerColor),

                        Divider(color: theme.dividerColor),

                        // Tổng Cộng
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Text(
                                'Tổng Cộng',
                                style: theme.textTheme.titleLarge,
                              ),
                              const Spacer(),
                              Text(
                                '${NumberFormat('#,###', 'vi_VN').format(totalAmount)} đ',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: kDarkGray,
                                  fontWeight: FontWeight.bold,
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
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: kMediumGray),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng trống',
            style: theme.textTheme.titleLarge?.copyWith(color: kMediumGray),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: theme.textTheme.bodyLarge?.copyWith(color: kMediumGray),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: theme.elevatedButtonTheme.style?.copyWith(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            child: Text('Tiếp tục mua sắm', style: theme.textTheme.labelLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.cardColor,
          border: Border.all(
            color: theme.primaryColor.withOpacity(isSelected ? 1 : 0.3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? kWhite : theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final theme = Theme.of(context);
    final numberFormat = NumberFormat('#,###', 'vi_VN');

    // Lấy tên size từ size object hoặc fallback theo sizeId
    String sizeName = '';
    if (item.productDetails.size != null) {
      sizeName = item.productDetails.size!.name;
    } else {
      sizeName = _getSizeName(item.productDetails.sizeId);
    }

    // Lấy image URL
    String imageUrl = item.productDetails.imageUrl;

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
                        print('Image load error: $error');
                        return Container(
                          width: 60,
                          height: 60,
                          color: kLightGray,
                          child: Icon(
                            Icons.image_not_supported,
                            color: kMediumGray,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 60,
                          height: 60,
                          color: kLightGray,
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    )
                    : Container(
                      width: 60,
                      height: 60,
                      color: kLightGray,
                      child: Icon(Icons.image, color: kMediumGray),
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: $sizeName',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kMediumGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${numberFormat.format(item.productDetails.price)} đ x ${item.quantity}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: kMediumGray,
                  ),
                ),
              ],
            ),
          ),

          // Điều khiển số lượng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: theme.primaryColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _updateQuantity(item, item.quantity - 1),
                  child: Icon(
                    Icons.remove,
                    size: 18,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${item.quantity}', style: theme.textTheme.labelMedium),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _updateQuantity(item, item.quantity + 1),
                  child: Icon(Icons.add, size: 18, color: theme.primaryColor),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Giá và nút xóa
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${numberFormat.format(item.totalPrice)} đ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: kDarkGray,
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
    final theme = Theme.of(context);
    final numberFormat = NumberFormat('#,###', 'vi_VN');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
                Text('Tổng cộng:', style: theme.textTheme.titleMedium),
                Text(
                  '${numberFormat.format(totalAmount)}đ',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: kDarkGray,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CheckoutScreen(
                            cartId: cartId!,
                            cartItems: cartItems,
                            totalAmount: totalAmount1,
                          ),
                    ),
                  );
                },
                style: theme.elevatedButtonTheme.style?.copyWith(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                child: Text(
                  'Tiến hành thanh toán',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToCheckout() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giỏ hàng trống'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder:
    //         (context) =>
    //             CheckoutScreen(cartItems: cartItems, totalAmount: totalAmount),
    //   ),
    // );
  }
}
