import 'package:app_selldrinks/models/product.dart';
import 'package:app_selldrinks/screens/prod_detail_screen.dart';
import 'package:app_selldrinks/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BestSellerList extends StatefulWidget {
  const BestSellerList({super.key});

  @override
  State<BestSellerList> createState() => _BestSellerListState();
}

class _BestSellerListState extends State<BestSellerList> {
  List<Product> _bestSellers = [];
  bool _isLoadingProducts = true;
  String _productError = '';
  final NumberFormat numberFormat = NumberFormat('#,###', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _loadBestSellers();
  }

  Future<void> _loadBestSellers() async {
    try {
      setState(() {
        _isLoadingProducts = true;
        _productError = '';
      });

      print('BestSellerList - Starting to load products...');
      final products = await ProductService.getProducts();

      print('BestSellerList - Loaded ${products.length} products');

      // Lấy tối đa 10 sản phẩm đầu tiên làm "bán chạy nhất"
      setState(() {
        _bestSellers = products.take(10).toList();
        _isLoadingProducts = false;
      });

      print('BestSellerList - Best sellers count: ${_bestSellers.length}');

      // Log từng sản phẩm để debug
      for (int i = 0; i < _bestSellers.length; i++) {
        final product = _bestSellers[i];
        print('BestSeller $i: ${product.name} - ${product.priceRange}');
      }
    } catch (e, stackTrace) {
      print('BestSellerList - Error loading products: $e');
      print('BestSellerList - Stack trace: $stackTrace');
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
                  color: const Color(0xFF383838), // Dark Gray
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigator đến trang xem tất cả sản phẩm
                  print('Navigate to all products');
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: Color(0xFF383838)), // Dark Gray
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
        child: CircularProgressIndicator(color: Color(0xFF383838)), // Dark Gray
      );
    }

    if (_productError.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
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
          style: TextStyle(color: Color(0xFF383838), fontSize: 14), // Dark Gray
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
            print('Tapped on product: ${product.name} (ID: ${product.id})');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProductDetailScreen(productId: product.id),
              ),
            );
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
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5), // Light Gray
                        borderRadius: BorderRadius.vertical(
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
                    // Badge sale nếu có discount
                    if (_hasDiscount(product))
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Sale',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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
                            color: Color(0xFF383838), // Dark Gray
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
                            const Text(
                              '4.5', // Giá trị mặc định
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF808080), // Medium Gray
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '(100+)', // Giá trị mặc định
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF808080), // Medium Gray
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Hiển thị giá
                        _buildPriceDisplay(product),
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
        color: const Color(0xFFF5F5F5), // Light Gray
        child: const Icon(
          Icons.image_not_supported,
          size: 40,
          color: Color(0xFF808080), // Medium Gray
        ),
      );
    }

    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Image load error for $productName: $error');
        return Container(
          color: const Color(0xFFF5F5F5), // Light Gray
          child: const Icon(
            Icons.broken_image,
            size: 40,
            color: Color(0xFF808080), // Medium Gray
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFF5F5F5), // Light Gray
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFF383838), // Dark Gray
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

  // Widget hiển thị giá sản phẩm
  Widget _buildPriceDisplay(Product product) {
    // Sử dụng priceRange string từ Product model
    return Text(
      product.priceRange,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Color(0xFF383838), // Dark Gray
      ),
    );
  }

  // Kiểm tra sản phẩm có giảm giá không
  bool _hasDiscount(Product product) {
    // Tạm thời return false vì SimpleProductDetail không có oldprice
    // Bạn có thể implement logic này sau
    return false;
  }
}
