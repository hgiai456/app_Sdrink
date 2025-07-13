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

  @override
  void initState() {
    super.initState();
    fetchProductDetail();
  }

  Future<void> fetchProductDetail() async {
    try {
      final data = await ProductService.getProductDetail(widget.productId);
      setState(() {
        productDetail = data;
        _sizes = data['sizes'] ?? [];
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
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (productDetail == null)
      return const Center(child: Text('Không tìm thấy sản phẩm'));
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
                          final isSelected =
                              _selectedSizeName == size['size_name'];
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
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              style: highlandsTheme.elevatedButtonTheme.style,
              onPressed:
                  (_selectedSizePrice != null && _sizes.isNotEmpty)
                      ? () {}
                      : null,
              child: Text(
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
