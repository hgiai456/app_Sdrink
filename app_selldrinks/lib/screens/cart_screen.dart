import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  bool isCheckingOut = false;

  // Controllers cho form thanh toán
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCartItems() async {
    try {
      setState(() {
        isLoading = true;
      });

      print('=== CART SCREEN DEBUG ===');
      final items = await CartService.getCartItems();
      print('CartScreen - Received ${items.length} items');
      print('CartScreen - Items: $items');

      setState(() {
        cartItems = items;
        isLoading = false;
      });

      print('CartScreen - State updated with ${cartItems.length} items');
      print('CartScreen - cartItems.isEmpty: ${cartItems.isEmpty}');
      print('========================');
    } catch (e) {
      print('CartScreen - Error loading cart items: $e');
      setState(() {
        cartItems = [];
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải giỏ hàng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double _calculateTotal() {
    return cartItems.fold(0.0, (total, item) {
      final price = (item['product_detail']?['price'] ?? 0).toDouble();
      final quantity = item['quantity'] ?? 0;
      return total + (price * quantity);
    });
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

  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeItem(index);
      return;
    }

    try {
      final cartItemId = cartItems[index]['id'];

      // Cập nhật trong UI trước
      setState(() {
        cartItems[index]['quantity'] = newQuantity;
      });

      // Gọi API cập nhật
      await CartService.updateCartItemQuantity(cartItemId, newQuantity);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật số lượng'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating quantity: $e');
      // Reload lại để đồng bộ dữ liệu
      _loadCartItems();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeItem(int index) async {
    try {
      final cartItemId = cartItems[index]['id'];

      // Xóa khỏi UI trước
      setState(() {
        cartItems.removeAt(index);
      });

      // Gọi API xóa
      await CartService.removeCartItem(cartItemId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa sản phẩm'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error removing item: $e');
      // Reload lại để đồng bộ dữ liệu
      _loadCartItems();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xóa sản phẩm: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkout() async {
    if (_phoneController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập đầy đủ thông tin số điện thoại và địa chỉ',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isCheckingOut = true;
    });

    try {
      await CartService.checkoutCart(
        phone: _phoneController.text,
        address: _addressController.text,
        note: _noteController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form và tải lại giỏ hàng
        _phoneController.clear();
        _addressController.clear();
        _noteController.clear();
        _loadCartItems();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đặt hàng: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isCheckingOut = false;
        });
      }
    }
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thông tin đặt hàng'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại *',
                      hintText: 'Nhập số điện thoại',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ giao hàng *',
                      hintText: 'Nhập địa chỉ giao hàng',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú (không bắt buộc)',
                      hintText: 'Ghi chú cho đơn hàng',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tổng tiền: ${NumberFormat('#,### đ').format(_calculateTotal())}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed:
                    isCheckingOut
                        ? null
                        : () {
                          Navigator.pop(context);
                          _checkout();
                        },
                child:
                    isCheckingOut
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Đặt hàng'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2B1B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearCartDialog(),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCartItems,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4B2B1B)),
                ),
              )
              : cartItems.isEmpty
              ? _buildEmptyCart()
              : _buildCartContent(),
      bottomNavigationBar: cartItems.isNotEmpty ? _buildBottomBar() : null,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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

  Widget _buildCartContent() {
    return Column(
      children: [
        // Header thông tin
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Text(
            'Bạn có ${cartItems.length} sản phẩm trong giỏ hàng',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4B2B1B),
            ),
          ),
        ),

        // Danh sách sản phẩm
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadCartItems,
            color: const Color(0xFF4B2B1B),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return _buildCartItem(cartItems[index], index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    print('Building cart item: $item');
    // Xử lý dữ liệu an toàn
    final productDetail = item['product_detail'] as Map<String, dynamic>?;
    final productName = productDetail?['name'] ?? 'Sản phẩm không xác định';
    final price = productDetail?['price'] ?? 0;
    final oldPrice = productDetail?['oldprice'];
    final quantity = item['quantity'] ?? 1;
    final sizeId = productDetail?['size_id'] ?? 0;
    final sizeName = _getSizeName(sizeId);

    // Xử lý hình ảnh - thử nhiều key có thể
    String productImage = '';
    if (productDetail != null) {
      productImage =
          productDetail['img1'] ??
          productDetail['image'] ??
          productDetail['img'] ??
          '';
    }

    final totalPrice =
        (price is int ? price : int.tryParse(price.toString()) ?? 0) *
        (quantity is int ? quantity : int.tryParse(quantity.toString()) ?? 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  productImage.isNotEmpty
                      ? Image.network(
                        productImage,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Image error: $error');
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      )
                      : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
            ),

            const SizedBox(width: 16),

            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B2B1B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Size: $sizeName',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 8),

                  // Giá
                  Row(
                    children: [
                      Text(
                        '${_formatPrice(price)} đ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B2B1B),
                        ),
                      ),
                      if (oldPrice != null && oldPrice > price) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${_formatPrice(oldPrice)} đ',
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Điều khiển số lượng và tổng tiền
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Điều khiển số lượng
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _updateQuantity(index, quantity - 1),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: Color(0xFF4B2B1B),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _updateQuantity(index, quantity + 1),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Color(0xFF4B2B1B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tổng tiền
                      Text(
                        '${_formatPrice(totalPrice)} đ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Nút xóa
            IconButton(
              onPressed: () => _showRemoveItemDialog(index),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final totalAmount = cartItems.fold<int>(0, (sum, item) {
      final productDetail = item['product_detail'] as Map<String, dynamic>?;
      int price = productDetail?['price'] ?? 0;
      int quantity = item['quantity'] ?? 1;
      return sum + (price * quantity);
    });

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
                  '${_formatPrice(totalAmount)} đ',
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
                onPressed: () => _proceedToCheckout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B2B1B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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

  // Helper methods
  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showRemoveItemDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
<<<<<<< HEAD
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn Cửa Hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              ...stores.map(
                (store) => ListTile(
                  title: Text(store.name),
                  subtitle: Text(store.fullAddress),
                  leading: Radio<Store>(
                    value: store,
                    groupValue: selectedStore,
                    onChanged: (Store? value) {
                      setState(() {
                        selectedStore = value;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    setState(() {
                      selectedStore = store;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
=======
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có muốn xóa sản phẩm này khỏi giỏ hàng?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeItem(index);
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
>>>>>>> 26a31fe0305091359ae3bb2ae9296f7492a75ff2
        );
      },
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có muốn xóa toàn bộ giỏ hàng?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearCart();
              },
              child: const Text(
                'Xóa tất cả',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _proceedToCheckout() {
    // TODO: Implement checkout logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng thanh toán đang được phát triển'),
      ),
    );
  }

  Future<void> _clearCart() async {
    try {
      // TODO: Implement clear cart API
      setState(() {
        cartItems.clear();
      });

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
}
