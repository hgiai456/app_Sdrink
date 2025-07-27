import 'package:flutter/material.dart';
import 'package:app_selldrinks/screens/prod_detail_screen.dart';
import 'package:app_selldrinks/screens/search_screen.dart';
import '../services/product_service.dart';

// Theme colors
const Color kDarkGray = Color(0xFF383838);
const Color kMediumGray = Color(0xFF808080);
const Color kLightGray = Color(0xFFF5F5F5);
const Color kWhite = Color(0xFFFFFFFF);

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  _OrderScreen createState() => _OrderScreen();
}

class _OrderScreen extends State<OrderScreen> {
  int _selectedCategoryIndex = 0;
  List categories = [];
  List products = [];
  bool isLoading = false;
  int? selectedCategoryId;

  final ScrollController _scrollController = ScrollController();
  late ScrollController _categoryScrollController;

  @override
  void initState() {
    super.initState();
    _categoryScrollController = ScrollController();
    loadCategories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadCategories() async {
    setState(() => isLoading = true);
    try {
      categories = await ProductService.fetchCategories();
      if (categories.isNotEmpty) {
        setState(() {
          selectedCategoryId = categories[0]['id'];
        });
        await loadProductsByCategory(selectedCategoryId!);
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> loadProductsByCategory(int categoryId) async {
    setState(() => isLoading = true);
    try {
      final result = await ProductService.fetchProductsByCategory(categoryId);
      setState(() {
        products = result;
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
    setState(() => isLoading = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Logic load more có thể thêm ở đây
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGray,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: kWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              child: Container(
                height: 35,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: kLightGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kMediumGray.withOpacity(0.3)),
                ),
                child: const Center(
                  child: TextField(
                    enabled: false,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm món ăn...',
                      hintStyle: TextStyle(color: kMediumGray, fontSize: 15),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      suffixIcon: Icon(
                        Icons.search,
                        color: kMediumGray,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kDarkGray),
                ),
              )
              : Column(
                children: [
                  // Category Section
                  Container(
                    height: 150, // Tăng height từ 110 lên 120
                    color: kWhite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Text(
                            'Danh mục',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: kDarkGray,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _categoryScrollController,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ), // Thêm vertical padding
                            child: Row(
                              children: List.generate(categories.length, (
                                index,
                              ) {
                                final category = categories[index];
                                final isSelected =
                                    _selectedCategoryIndex == index;
                                return GestureDetector(
                                  onTap: () async {
                                    final currentOffset =
                                        _categoryScrollController.offset;
                                    setState(() {
                                      _selectedCategoryIndex = index;
                                      selectedCategoryId = category['id'];
                                    });
                                    await loadProductsByCategory(
                                      selectedCategoryId!,
                                    );
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (_categoryScrollController
                                              .hasClients) {
                                            _categoryScrollController.jumpTo(
                                              currentOffset,
                                            );
                                          }
                                        });
                                  },
                                  child: Container(
                                    width: 85, // Tăng width từ 75 lên 85
                                    height: 100, // Tăng height từ 80 lên 85
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? kDarkGray : kWhite,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? kDarkGray
                                                : kMediumGray.withOpacity(0.3),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              isSelected
                                                  ? kDarkGray.withOpacity(0.2)
                                                  : Colors.black.withOpacity(
                                                    0.05,
                                                  ),
                                          blurRadius: isSelected ? 8 : 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        10,
                                      ), // Tăng padding từ 8 lên 10
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Category Image
                                          Container(
                                            width: 45, // Tăng từ 40 lên 45
                                            height: 45, // Tăng từ 40 lên 45
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color:
                                                  isSelected
                                                      ? kWhite.withOpacity(0.2)
                                                      : kLightGray,
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child:
                                                category['image'] != null &&
                                                        category['image']
                                                            .isNotEmpty
                                                    ? Image.network(
                                                      category['image'],
                                                      fit: BoxFit.cover,
                                                      width: 45,
                                                      height: 45,
                                                      loadingBuilder: (
                                                        context,
                                                        child,
                                                        loadingProgress,
                                                      ) {
                                                        if (loadingProgress ==
                                                            null)
                                                          return child;
                                                        return Container(
                                                          width: 45,
                                                          height: 45,
                                                          color:
                                                              isSelected
                                                                  ? kWhite
                                                                      .withOpacity(
                                                                        0.2,
                                                                      )
                                                                  : kLightGray,
                                                          child: Center(
                                                            child: SizedBox(
                                                              width: 20,
                                                              height: 20,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                      Color
                                                                    >(
                                                                      isSelected
                                                                          ? kWhite
                                                                          : kMediumGray,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => Container(
                                                            width: 45,
                                                            height: 45,
                                                            color:
                                                                isSelected
                                                                    ? kWhite
                                                                        .withOpacity(
                                                                          0.2,
                                                                        )
                                                                    : kLightGray,
                                                            child: Icon(
                                                              Icons
                                                                  .restaurant_menu,
                                                              color:
                                                                  isSelected
                                                                      ? kWhite
                                                                      : kMediumGray,
                                                              size:
                                                                  24, // Tăng icon size từ 20 lên 24
                                                            ),
                                                          ),
                                                    )
                                                    : Container(
                                                      width: 45,
                                                      height: 45,
                                                      color:
                                                          isSelected
                                                              ? kWhite
                                                                  .withOpacity(
                                                                    0.2,
                                                                  )
                                                              : kLightGray,
                                                      child: Icon(
                                                        Icons.restaurant_menu,
                                                        color:
                                                            isSelected
                                                                ? kWhite
                                                                : kMediumGray,
                                                        size:
                                                            24, // Tăng icon size từ 20 lên 24
                                                      ),
                                                    ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ), // Tăng spacing từ 4 lên 6
                                          // Category Name
                                          Flexible(
                                            child: Text(
                                              category['name'] ?? 'N/A',
                                              textAlign: TextAlign.center,
                                              maxLines:
                                                  2, // Cho phép 2 dòng thay vì 1
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color:
                                                    isSelected
                                                        ? kWhite
                                                        : kDarkGray,
                                                fontSize:
                                                    11, // Tăng từ 10 lên 11
                                                fontWeight: FontWeight.w500,
                                                height: 1.2, // Thêm line height
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Products Section
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Sản phẩm',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: kDarkGray,
                                  ),
                                ),
                                Text(
                                  '${products.length} món',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: kMediumGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: products.length,
                              separatorBuilder:
                                  (context, index) => const Divider(
                                    color: kLightGray,
                                    thickness: 1,
                                    height: 1,
                                  ),
                              itemBuilder: (context, index) {
                                final product = products[index];
                                final isOutOfStock =
                                    product['status'] == 'HẾT HÀNG';

                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ProductDetailScreen(
                                              productId: product['id'],
                                            ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        // Product Image
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: kLightGray,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child:
                                                product['image'] != null &&
                                                        product['image']
                                                            .isNotEmpty
                                                    ? Image.network(
                                                      product['image'],
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => Container(
                                                            color: kLightGray,
                                                            child: const Icon(
                                                              Icons.restaurant,
                                                              color:
                                                                  kMediumGray,
                                                              size: 32,
                                                            ),
                                                          ),
                                                    )
                                                    : Container(
                                                      color: kLightGray,
                                                      child: const Icon(
                                                        Icons.restaurant,
                                                        color: kMediumGray,
                                                        size: 32,
                                                      ),
                                                    ),
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        // Product Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['name'] ??
                                                    'Không có tên',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      isOutOfStock
                                                          ? kMediumGray
                                                          : kDarkGray,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              if (product['description'] !=
                                                      null &&
                                                  product['description']
                                                      .isNotEmpty)
                                                Text(
                                                  product['description'],
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: kMediumGray,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Price
                                                  Text(
                                                    product['product_details'] !=
                                                                null &&
                                                            product['product_details']
                                                                .isNotEmpty
                                                        ? '${product['product_details'][0]['price']} ₫'
                                                        : 'Liên hệ',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          isOutOfStock
                                                              ? kMediumGray
                                                              : kDarkGray,
                                                    ),
                                                  ),
                                                  // Status
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          isOutOfStock
                                                              ? Colors.red
                                                                  .withOpacity(
                                                                    0.1,
                                                                  )
                                                              : Colors.green
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      product['status'] ??
                                                          'CÒN HÀNG',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            isOutOfStock
                                                                ? Colors.red
                                                                : Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Arrow Icon
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          color: kMediumGray,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
}
