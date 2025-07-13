import 'package:app_selldrinks/models/product.dart';
import 'package:app_selldrinks/services/product_service.dart';
import 'package:flutter/material.dart';

class BestSellerList extends StatefulWidget {
  const BestSellerList({super.key});

  @override
  State<BestSellerList> createState() => _BestSellerListState();
}

class _BestSellerListState extends State<BestSellerList> {
  List<Product> _bestSellers = [];
  bool _isLoadingProducts = true;
  String _productError = '';

  @override
  void initState() {
    super.initState();
    _loadBestSellers();
  }

  // Hàm load sản phẩm bán chạy từ API
  Future<void> _loadBestSellers() async {
    try {
      setState(() {
        _isLoadingProducts = true;
        _productError = '';
      });

      final products = await ProductService.getProducts();

      // Lấy tối đa 10 sản phẩm đầu tiên làm "bán chạy nhất"
      // Bạn có thể thay đổi logic này tùy theo API
      setState(() {
        _bestSellers = products.take(10).toList();
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _productError = 'Không thể tải sản phẩm: ${e.toString()}';
        _isLoadingProducts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 280, child: _buildBestSellerSection());
  }

  Widget _buildBestSellerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bán chạy nhất',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4B2B1B), // Màu nâu từ theme
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigator đến trang xem tất cả sản phẩm
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: Color(0xFFA10F1A)), // Đỏ Highlands
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(height: 220, child: _buildProductList()),
      ],
    );
  }

  Widget _buildProductList() {
    if (_isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFA10F1A)),
      );
    }

    if (_productError.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              _productError,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadBestSellers,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_bestSellers.isEmpty) {
      return const Center(
        child: Text(
          'Không có sản phẩm nào',
          style: TextStyle(color: Color(0xFF4B2B1B), fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _bestSellers.length,
      itemBuilder: (context, index) {
        final product = _bestSellers[index];
        return GestureDetector(
          onTap: () {
            // Navigator đến chi tiết sản phẩm
            print('Tapped on product: ${product.name}');
          },
          child: Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((255 * 0.1).round()),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hình ảnh sản phẩm
                Stack(
                  children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: _buildProductImage(
                          product.imageUrl,
                          product.name,
                        ),
                      ),
                    ),
                    // Badge giảm giá (tùy chọn - có thể thêm logic tính giảm giá)
                    // Positioned(
                    //   top: 8,
                    //   left: 8,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 6,
                    //       vertical: 2,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: const Color(0xFFA10F1A),
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: const Text(
                    //       '20%',
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontSize: 10,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),

                // Thông tin sản phẩm
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF4B2B1B), // Màu nâu từ theme
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Rating và số lượng bán (mặc định vì API không có)
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '4.5', // Giá trị mặc định
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(100+)', // Giá trị mặc định
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Giá từ ProDetails
                        Row(
                          children: [
                            Text(
                              '${_getProductPrice(product)} VNĐ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFFA10F1A), // Đỏ Highlands
                              ),
                            ),
                            // Có thể thêm giá gốc nếu có logic giảm giá
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget để hiển thị hình ảnh sản phẩm với fallback
  Widget _buildProductImage(String? imagePath, String productName) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey,
        ),
      );
    }

    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFFA10F1A),
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          ),
        );
      },
    );
  }

  int _getProductPrice(Product product) {
    final price = product.price;
    return price;
  }
}
