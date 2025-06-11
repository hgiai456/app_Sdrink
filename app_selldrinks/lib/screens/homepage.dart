import 'package:app_selldrinks/screens/products_list_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/bannerhome.dart';
import '../models/bestseller.dart';
import '../models/loaisphome.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<LoaiSpHome> _loaiSanPhams = LoaiSpHome.getSampleData();
  final List<BannerHome> _banners = BannerHome.getSampleData();
  final List<BestSeller> _bestSellers = BestSeller.getSampleData();

  @override
  void initState() {
    super.initState();
    _startBannerAutoSlide();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerAutoSlide() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentBannerIndex < _banners.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }
      _bannerController.animateToPage(
        _currentBannerIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Sử dụng màu nền từ theme
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với avatar và thanh tìm kiếm
              _buildHeader(),

              const SizedBox(height: 16),

              // Thanh loại sản phẩm
              _buildCategorySection(),

              const SizedBox(height: 20),

              // Banner tự động chuyển
              _buildBannerSection(),

              const SizedBox(height: 20),

              // Sản phẩm bán chạy
              _buildBestSellerSection(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    //Header
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((255 * 0.1).round()),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEFEAE5), // Màu nền nhạt
              border: Border.all(
                color: const Color(0xFFA10F1A),
                width: 2,
              ), // Đỏ Highlands
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFFA10F1A), // Đỏ Highlands
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Thanh tìm kiếm
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCCCCCC)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF4B2B1B),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Nút thông báo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEAE5), // Màu nền nhạt
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFFA10F1A), // Đỏ Highlands
                    size: 22,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(
                        0xFFA10F1A,
                      ), // Đỏ Highlands thay vì đỏ thường
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh mục sản phẩm',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4B2B1B), // Màu nâu từ theme
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: Color(0xFFA10F1A)), // Đỏ Highlands
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _loaiSanPhams.length,
            itemBuilder: (context, index) {
              final category = _loaiSanPhams[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductListScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFEFEAE5,
                          ), // Màu nền nhạt từ theme
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFFA10F1A,
                            ).withAlpha((255 * 0.3).round()),
                          ), // Đỏ Highlands nhạt
                        ),
                        child: Icon(
                          _getCategoryIcon(category.tenLoai),

                          color: const Color(0xFFA10F1A), // Đỏ Highlands
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.tenLoai,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4B2B1B), // Màu nâu từ theme
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSection() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Background image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildBannerImage(banner.hinhAnh),
                    ),

                    // Content chỉ còn nút xem ngay
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.end, // Đẩy nút xuống dưới
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              debugPrint('Navigate to: ${banner.linkDen}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFA10F1A),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              'Xem ngay',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentBannerIndex == index
                        ? const Color(0xFFA10F1A) // Đỏ Highlands
                        : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget để hiển thị hình ảnh banner với fallback
  Widget _buildBannerImage(String imagePath) {
    return Image.asset(
      imagePath,
      width: double.infinity,
      height: 160,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Nếu không tìm thấy hình ảnh, hiển thị hình mặc định
        return Image.asset(
          'assets/images/coffee-beans.png',
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Nếu cả hình mặc định cũng không có, hiển thị background màu với icon
            return Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFA10F1A),
                    const Color(0xFF8B0E17),
                  ], // Gradient đỏ Highlands
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.local_cafe, size: 60, color: Colors.white),
              ),
            );
          },
        );
      },
    );
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
                onPressed: () {},
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: Color(0xFFA10F1A)), // Đỏ Highlands
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _bestSellers.length,
            itemBuilder: (context, index) {
              final product = _bestSellers[index];
              return Container(
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
                              product.hinhAnh,
                              product.tenSanPham,
                            ),
                          ),
                        ),
                        if (product.coGiamGia)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFA10F1A,
                                ), // Đỏ Highlands thay vì đỏ thường
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${(((product.giaGoc - product.gia) / product.giaGoc) * 100).round()}%',
                                style: const TextStyle(
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
                              product.tenSanPham,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF4B2B1B), // Màu nâu từ theme
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            // Rating và số lượng bán
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${product.danhGia}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${product.soLuongBan})',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            // Giá
                            Row(
                              children: [
                                Text(
                                  '${product.gia.toInt()}đ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFFA10F1A), // Đỏ Highlands
                                  ),
                                ),
                                if (product.coGiamGia) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '${product.giaGoc.toInt()}đ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget để hiển thị hình ảnh sản phẩm với fallback
  Widget _buildProductImage(String imagePath, String productName) {
    return Image.asset(
      imagePath,
      width: double.infinity,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Nếu không tìm thấy hình ảnh, hiển thị hình mặc định
        return Image.asset(
          'assets/images/coffee-beans.png',
          width: double.infinity,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Nếu cả hình mặc định cũng không có, hiển thị icon
            return Container(
              width: double.infinity,
              height: 100,
              color: Colors.grey[200],
              child: Icon(
                _getProductIcon(productName),
                size: 40,
                color: const Color(0xFFA10F1A),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'cà phê':
        return Icons.local_cafe;
      case 'trà sữa':
        return Icons.local_drink;
      case 'sinh tố':
        return Icons.blender;
      case 'bánh ngọt':
        return Icons.cake;
      case 'nước ép':
        return Icons.local_bar;
      case 'đồ ăn nhẹ':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }

  IconData _getProductIcon(String productName) {
    if (productName.toLowerCase().contains('cà phê') ||
        productName.toLowerCase().contains('cappuccino')) {
      return Icons.local_cafe;
    } else if (productName.toLowerCase().contains('trà sữa')) {
      return Icons.local_drink;
    } else if (productName.toLowerCase().contains('bánh')) {
      return Icons.cake;
    } else if (productName.toLowerCase().contains('sinh tố')) {
      return Icons.blender;
    } else {
      return Icons.restaurant;
    }
  }
}
