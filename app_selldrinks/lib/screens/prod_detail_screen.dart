import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';
import '../services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String? _selectedSizeName;
  int? _selectedSizePrice;
  int? _selectedSizeQuantity;
  List<dynamic> _sizes = [];
  Map<String, dynamic>? productDetail;
  bool isLoading = true;
  final TextEditingController _noteController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> fetchProductDetail() async {
    try {
      final data = await ProductService.getProductDetail(widget.productId);
      setState(() {
        productDetail = data;
        _sizes = data['sizes'] ?? [];
        for (var size in _sizes) {
          switch (size['size_id']) {
            // size_id sẽ được set mặc định size_name là S,M,L theo API
            case 1:
              size['size_name'] = 'S';
              break;

            case 2:
              size['size_name'] = 'M';
              break;

            case 3:
              size['size_name'] = 'L';
              break;

            default:
              size['size_name'] = 'Khác';
          }
        }
        final seen = <int>{}; //Hàm xử lý trùng size
        _sizes =
            _sizes.where((size) {
              if (seen.contains(size['size_id'])) return false;
              seen.add(size['size_id']);
              return true;
            }).toList();

        if (_sizes.isNotEmpty) {
          _selectedSizeName = _sizes[0]['size_name'];
          _selectedSizePrice = _sizes[0]['price'];
          _selectedSizeQuantity = _sizes[0]['quantity'];
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching product detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF383838),
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Đang tải thông tin sản phẩm...',
                style: TextStyle(color: Color(0xFF808080), fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (productDetail == null) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Color(0xFF808080)),
              SizedBox(height: 16),
              Text(
                'Không tìm thấy sản phẩm',
                style: TextStyle(
                  color: Color(0xFF383838),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = productDetail!;
    int totalPrice = _quantity * (_selectedSizePrice ?? 0);

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Product Image Section
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child:
                      data['image'] != null &&
                              data['image'].toString().isNotEmpty
                          ? Image.network(
                            data['image'],
                            width: double.infinity,
                            height: 320,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Color(0xFFF5F5F5),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Color(0xFF808080),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Không thể tải hình ảnh',
                                          style: TextStyle(
                                            color: Color(0xFF808080),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          )
                          : Container(
                            width: double.infinity,
                            height: 320,
                            color: Color(0xFFF5F5F5),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 48,
                                    color: Color(0xFF808080),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Chưa có hình ảnh',
                                    style: TextStyle(
                                      color: Color(0xFF808080),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                ),

                // Close Button
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Color(0xFF383838),
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product Info Section
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  // Product Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          data['name'] ?? '',
                          style: TextStyle(
                            color: Color(0xFF383838),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF383838),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _selectedSizePrice != null
                              ? NumberFormat(
                                '#,### đ',
                              ).format(_selectedSizePrice)
                              : 'N/A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Description
                  Text(
                    data['description'] ?? '',
                    style: TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Additional Info
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phần trang trí có thể bị ảnh hưởng khi vận chuyển.',
                          style: TextStyle(
                            color: Color(0xFF808080),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Giá đã bao gồm 8% VAT.',
                          style: TextStyle(
                            color: Color(0xFF808080),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Size Selection
                  Text(
                    'Chọn kích thước',
                    style: TextStyle(
                      color: Color(0xFF383838),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 12),

                  Row(
                    children:
                        _sizes.map<Widget>((size) {
                          final isSelected =
                              _selectedSizeName == size['size_name'];
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 8),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isSelected
                                          ? Color(0xFF383838)
                                          : Colors.white,
                                  side: BorderSide(
                                    color:
                                        isSelected
                                            ? Color(0xFF383838)
                                            : Color(
                                              0xFF808080,
                                            ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: isSelected ? 2 : 0,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedSizeName = size['size_name'];
                                    _selectedSizePrice = size['price'];
                                    _selectedSizeQuantity = size['quantity'];
                                  });
                                },
                                child: Text(
                                  size['size_name'] ?? '',
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Color(0xFF383838),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),

                  SizedBox(height: 24),

                  // Notes Section
                  Row(
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        color: Color(0xFF383838),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ghi Chú',
                        style: TextStyle(
                          color: Color(0xFF383838),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' (không bắt buộc)',
                        style: TextStyle(
                          color: Color(0xFF808080),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF808080).withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Nhập ghi chú cho đơn hàng...',
                        hintStyle: TextStyle(
                          color: Color(0xFF808080),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: 3,
                      style: TextStyle(color: Color(0xFF383838), fontSize: 14),
                    ),
                  ),

                  SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quantity Controls
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF808080).withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove,
                      color:
                          _quantity > 1 ? Color(0xFF383838) : Color(0xFF808080),
                      size: 20,
                    ),
                    onPressed:
                        _quantity > 1
                            ? () {
                              setState(() {
                                _quantity--;
                              });
                            }
                            : null,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_quantity',
                      style: TextStyle(
                        color: Color(0xFF383838),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Color(0xFF383838), size: 20),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
            ),

            SizedBox(width: 16),

            // Add to Cart Button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF383838),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed:
                    (_selectedSizePrice != null && _sizes.isNotEmpty)
                        ? () {
                          // Add to cart logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã thêm ${data['name']} vào giỏ hàng',
                              ),
                              backgroundColor: Color(0xFF383838),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                        : null,
                child: Text(
                  'THÊM ${NumberFormat('#,### đ').format(totalPrice)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
