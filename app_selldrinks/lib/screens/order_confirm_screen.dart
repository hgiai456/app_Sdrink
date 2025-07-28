import 'package:flutter/material.dart';
import 'package:app_selldrinks/services/cart_service.dart';
import 'package:app_selldrinks/services/payos_service.dart';
import 'package:app_selldrinks/screens/home_screen.dart';
import 'package:app_selldrinks/screens/payment_qr_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OrderConfirmScreen extends StatefulWidget {
  final int cartId;
  final int totalAmount;
  final String defaultName;
  final String defaultPhone;
  final String defaultAddress;

  const OrderConfirmScreen({
    Key? key,
    required this.cartId,
    required this.totalAmount,
    required this.defaultName,
    required this.defaultPhone,
    required this.defaultAddress,
  }) : super(key: key);

  @override
  _OrderConfirmScreenState createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
  final _formKey = GlobalKey<FormState>();
  final CartService _cartService = CartService();
  final PayOSService _payOSService = PayOSService();

  // Controllers cho các field
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final TextEditingController _noteController = TextEditingController();

  bool isProcessing = false;
  bool isDelivery = true;
  String paymentMethod = 'cod'; // 'cod' hoặc 'online'

  @override
  void initState() {
    super.initState();
    // Khởi tạo controllers với giá trị mặc định
    _nameController = TextEditingController(text: widget.defaultName);
    _phoneController = TextEditingController(text: widget.defaultPhone);
    _addressController = TextEditingController(text: widget.defaultAddress);
    _noteController.text = "Đơn hàng từ app";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleOnlinePayment() async {
    try {
      // Tạo mã đơn hàng
      final orderCode = PayOSService.generateOrderCode();
      final description = 'Ma hoa don $orderCode';

      print('🔄 Creating PayOS payment for order: $orderCode');

      // Tạo link thanh toán PayOS
      final paymentResult = await _payOSService.createPaymentLink(
        orderCode: orderCode,
        amount: widget.totalAmount,
        description: description,
        buyerName: _nameController.text.trim(),
        buyerPhone: _phoneController.text.trim(),
        buyerAddress: _addressController.text.trim(),
      );

      print('💰 Payment Result: $paymentResult');

      // ✅ SỬA LỖI: Kiểm tra đúng cách
      if (paymentResult['success'] == true) {
        // ✅ Kiểm tra dữ liệu QR
        final qrCode = paymentResult['qrCode'];

        if (qrCode != null && qrCode.isNotEmpty) {
          print('✅ QR Code created successfully, navigating to payment screen');

          // Chuyển đến màn hình QR thanh toán
          final paymentSuccess = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PaymentQRScreen(
                    qrData: qrCode,
                    orderCode: orderCode,
                    amount: widget.totalAmount,
                    description: description,
                  ),
            ),
          );

          print('💳 Payment screen result: $paymentSuccess');

          if (paymentSuccess == true) {
            await _completeOrder(orderCode);
          } else {
            print('❌ Payment was cancelled or failed');
            // Không làm gì, user đã hủy thanh toán
          }
        } else {
          throw Exception(
            'Không thể tạo mã QR thanh toán - QR code is null or empty',
          );
        }
      } else {
        throw Exception(
          paymentResult['message'] ?? 'Lỗi tạo thanh toán - PayOS API failed',
        );
      }
    } catch (e) {
      print('🚨 Error in _handleOnlinePayment: $e');
      rethrow; // Ném lỗi lên để _handleConfirmOrder catch
    }
  }

  Future<void> _handleCODPayment() async {
    try {
      // Tạo mã đơn hàng cho COD
      final orderCode = PayOSService.generateOrderCode();
      print('🛒 Processing COD order: $orderCode');
      await _completeOrder(orderCode);
    } catch (e) {
      print('🚨 Error in _handleCODPayment: $e');
      rethrow;
    }
  }

  Future<void> _completeOrder(int orderCode) async {
    try {
      print('📝 Completing order: $orderCode');

      // Lưu thông tin cập nhật
      await _saveUpdatedInfo();

      // Gọi API checkout với mã đơn hàng
      final result = await _cartService.checkout(
        cartId: widget.cartId,
        phone: _phoneController.text.trim(),
        note: '${_noteController.text.trim()} - Ma don hang: $orderCode',
        address: _addressController.text.trim(),
      );

      print('✅ Order completed successfully: $result'); // ✅ SỬ DỤNG BIẾN result

      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Đặt hàng thành công! Mã: $orderCode'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Chuyển về màn hình chính
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('🚨 Error in _completeOrder: $e');
      rethrow;
    }
  }

  Future<void> _handleConfirmOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Hiển thị dialog xác nhận
    final confirm = await _showConfirmDialog();
    if (confirm != true) return;

    setState(() {
      isProcessing = true;
    });

    try {
      print('🎯 Payment method selected: $paymentMethod');

      if (paymentMethod == 'online') {
        await _handleOnlinePayment();
      } else {
        await _handleCODPayment();
      }
    } catch (e) {
      print('🚨 Error in _handleConfirmOrder: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi đặt hàng: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Xác nhận đặt hàng',
              style: TextStyle(
                color: Color(0xFF383838),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Tên:', _nameController.text),
                const SizedBox(height: 8),
                _buildInfoRow('SĐT:', _phoneController.text),
                const SizedBox(height: 8),
                _buildInfoRow('Địa chỉ:', _addressController.text),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Thanh toán:',
                  paymentMethod == 'cod'
                      ? 'Khi nhận hàng'
                      : 'Thanh toán online',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng tiền:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF383838),
                        ),
                      ),
                      Text(
                        NumberFormat('#,### đ').format(widget.totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF383838),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF808080),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  // ✅ THÊM DÒNG NÀY - QUAN TRỌNG!
                  'Hủy',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF383838),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _saveUpdatedInfo() async {
    final prefs = await SharedPreferences.getInstance();

    // Chỉ lưu nếu thông tin khác với mặc định
    if (_nameController.text.trim() != widget.defaultName) {
      await prefs.setString('userName', _nameController.text.trim());
    }
    if (_phoneController.text.trim() != widget.defaultPhone) {
      await prefs.setString('userPhone', _phoneController.text.trim());
    }
    if (_addressController.text.trim() != widget.defaultAddress) {
      await prefs.setString('userAddress', _addressController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF383838),
        title: const Text(
          'Xác nhận thông tin',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeaderSection(),
                    const SizedBox(height: 24),

                    // Delivery Options
                    _buildDeliveryOptions(),
                    const SizedBox(height: 24),

                    // Payment Method
                    _buildPaymentMethodSection(),
                    const SizedBox(height: 24),

                    // Customer Info Form
                    _buildCustomerInfoForm(),
                    const SizedBox(height: 24),

                    // Order Summary
                    _buildOrderSummary(),
                  ],
                ),
              ),
            ),

            // Bottom Action
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          const Icon(
            Icons.assignment_outlined,
            size: 48,
            color: Color(0xFF383838),
          ),
          const SizedBox(height: 8),
          const Text(
            'Xác nhận thông tin đặt hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF383838),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vui lòng kiểm tra và cập nhật thông tin nếu cần',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF383838),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPaymentOption(
                  '💵 Khi nhận hàng',
                  'cod',
                  paymentMethod == 'cod',
                  () => setState(() => paymentMethod = 'cod'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentOption(
                  '📱 Thanh toán online',
                  'online',
                  paymentMethod == 'online',
                  () => setState(() => paymentMethod = 'online'),
                ),
              ),
            ],
          ),
          if (paymentMethod == 'online') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bạn sẽ được chuyển đến màn hình quét mã QR để thanh toán',
                      style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String text,
    String value,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF383838) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF383838) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF383838),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức nhận hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF383838),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOptionButton('🚚 Giao hàng', isDelivery, () {
                  setState(() {
                    isDelivery = true;
                  });
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOptionButton('🏪 Tại quán', !isDelivery, () {
                  setState(() {
                    isDelivery = false;
                  });
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoForm() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin khách hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF383838),
            ),
          ),
          const SizedBox(height: 16),

          // Tên khách hàng
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Họ và tên *',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF383838)),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ tên';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Số điện thoại
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Số điện thoại *',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF383838)),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              if (!RegExp(r'^[0-9]{9,11}$').hasMatch(value.trim())) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Địa chỉ
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: isDelivery ? 'Địa chỉ giao hàng *' : 'Địa chỉ *',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF383838)),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập địa chỉ';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Ghi chú
          TextFormField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Ghi chú đơn hàng',
              prefixIcon: const Icon(Icons.note_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF383838)),
              ),
              hintText: 'Nhập ghi chú cho đơn hàng (tùy chọn)',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tóm tắt đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF383838),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tạm tính:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                NumberFormat('#,### đ').format(widget.totalAmount),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isDelivery ? 'Phí giao hàng:' : 'Phí dịch vụ:',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const Text(
                'Miễn phí',
                style: TextStyle(fontSize: 14, color: Colors.green),
              ),
            ],
          ),

          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF383838),
                ),
              ),
              Text(
                NumberFormat('#,### đ').format(widget.totalAmount),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF383838),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isProcessing ? null : _handleConfirmOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF383838),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              isProcessing
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(
                    paymentMethod == 'online'
                        ? '📱 THANH TOÁN ONLINE (${NumberFormat('#,### đ').format(widget.totalAmount)})'
                        : '🛒 XÁC NHẬN ĐẶT HÀNG (${NumberFormat('#,### đ').format(widget.totalAmount)})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF383838) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF383838) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF383838),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF808080),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF383838),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
