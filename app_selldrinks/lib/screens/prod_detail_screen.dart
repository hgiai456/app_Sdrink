import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../services/product_detail_service.dart';
import '../themes/highland_theme.dart';
import '../services/port.dart';

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
  int? _selectedSizeId;
  List<Map<String, dynamic>> _sizes = [];
  Map<String, dynamic>? productDetail;
  bool isLoading = true;
  bool isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  Future<void> fetchProductDetail() async {
    try {
      final data = await ProductService.getProductDetail(widget.productId);
      print('Full API response: $data'); // Debug full response

      setState(() {
        _sizes = List<Map<String, dynamic>>.from(data['sizes'] ?? []);

        // print('sizesData type: ${sizesData.runtimeType}');
        // print('sizesData: $sizesData');

        productDetail = data;

        final seen = <int>{};
        _sizes =
            _sizes.where((size) {
              final sizeMap = Map<String, dynamic>.from(
                size,
              ); // Ensure it's a Map
              if (seen.contains(sizeMap['size_id'])) return false;
              seen.add(sizeMap['size_id']);
              return true;
            }).toList();

        if (_sizes.isNotEmpty) {
          final firstSize = Map<String, dynamic>.from(
            _sizes[0],
          ); // Cast first element
          _selectedSizeName = firstSize['size_name'];
          _selectedSizePrice = firstSize['price'];
          _selectedSizeQuantity = firstSize['quantity'];
          _selectedSizeId = firstSize['size_id'];
        }
        print('Processed _sizes: $_sizes');
        isLoading = false;
      });
    } catch (e) {
      print('Error in fetchProductDetail: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addToCart() async {
    if (_selectedSizeId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn size')));
      return;
    }

    setState(() {
      isAddingToCart = true;
    });

    try {
      print('Step 1: Starting addToCart process');
      print('ProductId: ${widget.productId}, SizeId: $_selectedSizeId');

      print('Step 2: Calling ProductDetailService');
      final productDetail =
          await ProductDetailService.getProductDetailIdByProductAndSize(
            productId: widget.productId,
            sizeId: _selectedSizeId!,
          );

      print('Step 3: ProductDetailService result: $productDetail');

      if (productDetail == null) {
        throw Exception('Không tìm thấy thông tin product detail');
      }

      print(
        'Step 4: Calling CartService with productDetailId: ${productDetail.id}',
      );
      await CartService().addToCart(
        productDetailId: productDetail.id,
        quantity: _quantity,
      );

      print('Step 5: Successfully added to cart');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm sản phẩm vào giỏ hàng'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error in _addToCart: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (productDetail == null) {
      return const Center(child: Text('Không tìm thấy sản phẩm'));
    }
    final data = productDetail!;
    int totalPrice = _quantity * (_selectedSizePrice ?? 0);

    return Scaffold(
      backgroundColor: highlandsTheme.appBarTheme.foregroundColor,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 12.0,
              bottom: 16.0,
              left: 24.0,
              right: 24.0,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: Stack(
                children: [
                  data['image'] != null && data['image'].toString().isNotEmpty
                      ? Image.network(
                        data['image'],
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.grey,
                              child: const Center(
                                child: Text('Image not found'),
                              ),
                            ),
                      )
                      : Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.image, size: 60)),
                      ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color:
                            highlandsTheme
                                .bottomNavigationBarTheme
                                .unselectedItemColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: highlandsTheme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['name'] ?? '',
                    style: highlandsTheme.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _selectedSizePrice != null
                      ? NumberFormat('#,### VNĐ').format(_selectedSizePrice)
                      : 'N/A',
                  style: highlandsTheme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: highlandsTheme.scaffoldBackgroundColor,
              child: ListView(
                padding: const EdgeInsets.only(top: 0, left: 16.0, right: 16.0),
                children: [
                  Text(
                    data['description'] ?? '',
                    style: highlandsTheme.textTheme.bodyLarge,
                  ),
                  const Text(
                    'Phần trang trí có thể bị ảnh hưởng khi vận chuyển.',
                  ),
                  const Text('Giá đã bao gồm 8% VAT.'),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.grey, thickness: 1),
                  const SizedBox(height: 16),
                  Row(
                    children:
                        _sizes.map<Widget>((size) {
                          final isSelected = _selectedSizeId == size['size_id'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isSelected
                                        ? highlandsTheme.primaryColor
                                        : Colors.white,
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedSizeName = size['size_name'];
                                  _selectedSizePrice = size['price'];
                                  _selectedSizeQuantity = size['quantity'];
                                  _selectedSizeId = size['size_id'];
                                });
                              },
                              child: Text(
                                size['size_name'] ?? '',
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? highlandsTheme
                                              .textTheme
                                              .labelLarge
                                              ?.color
                                          : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.note, color: highlandsTheme.iconTheme.color),
                      const SizedBox(width: 8),
                      Text(
                        'Ghi Chú',
                        style: highlandsTheme.textTheme.bodyMedium,
                      ),
                      Text(
                        ' (không bắt buộc)',
                        style: highlandsTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ghi Chú',
                      border: highlandsTheme.inputDecorationTheme.border,
                      focusedBorder:
                          highlandsTheme.inputDecorationTheme.focusedBorder,
                      fillColor: highlandsTheme.inputDecorationTheme.fillColor,
                      contentPadding: const EdgeInsets.all(10),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: highlandsTheme.appBarTheme.foregroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  color: highlandsTheme.iconTheme.color,
                  onPressed:
                      _quantity > 1
                          ? () {
                            setState(() {
                              _quantity--;
                            });
                          }
                          : null,
                ),
                Text('$_quantity', style: highlandsTheme.textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.add),
                  color: highlandsTheme.iconTheme.color,
                  onPressed:
                      (_selectedSizeQuantity != null &&
                              _quantity < _selectedSizeQuantity!)
                          ? () {
                            setState(() {
                              _quantity++;
                            });
                          }
                          : null,
                ),
              ],
            ),
            ElevatedButton(
              style: highlandsTheme.elevatedButtonTheme.style,
              onPressed:
                  (_selectedSizePrice != null &&
                          _sizes.isNotEmpty &&
                          !isAddingToCart)
                      ? _addToCart
                      : null,
              child:
                  isAddingToCart
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
                        'THÊM ${NumberFormat('#,### đ').format(totalPrice)}',
                        style: highlandsTheme.textTheme.labelLarge,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
