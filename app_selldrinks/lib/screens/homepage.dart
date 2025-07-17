import 'package:app_selldrinks/components/best_seller_list.dart';
import 'package:app_selldrinks/components/category_list.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/bannerhome.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<BannerHome> _banners = BannerHome.getSampleData();

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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  kBottomNavigationBarHeight, // TRỪ ĐI chiều cao thanh bottom nav
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildBannerSection(),
                const SizedBox(height: 16),
                CategoryList(),
                const SizedBox(height: 20),
                BestSellerList(),
              ],
            ),
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
              color: const Color(0xFFF5F5F5), // Màu nền nhạt
              border: Border.all(
                color: const Color(0xFF383838),
                width: 2,
              ), // Dark Gray
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF383838), // Dark Gray
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Thanh tìm kiếm
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: TextStyle(color: Color(0xFF888080), fontSize: 14),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.search,
                      color: Color(0xFF383838),
                      size: 20,
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 40),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
              color: const Color(0xFFF5F5F5), // Màu nền nhạt
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF383838), // Dark Gray
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
                      color: Color(0xFF383838), // Dark Gray
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
                              foregroundColor: const Color(0xFF383838),
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
                        ? const Color(0xFF383838) // Dark Gray
                        : Color(0xFF808080),
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
                    const Color(0xFF383838),
                    const Color(0xFF808080),
                  ], // Gradient gray
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
}
