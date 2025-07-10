import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:app_selldrinks/screens/prod_detail_screen.dart';
import 'package:app_selldrinks/screens/search_screen.dart';
import '../services/product_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  _OrderScreen createState() => _OrderScreen();
}

class _OrderScreen extends State<OrderScreen> {
  int _selectedCategoryIndex = 0;
  List categories = [];
  List products = [];
  int currentPage = 1;
  int totalPageSize = 1;
  bool isLoading = false;
  bool isLoadingMore = false;
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
      debugPrint('Error loading categories: $e}');
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
      // loadMoreProducts(); // Removed as per edit hint
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: const Center(
                child: TextField(
                  enabled: false,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Tìm Kiếm Tên Món Ăn',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Danh mục sản phẩm
                SizedBox(
                  height: 100,
                  child: SingleChildScrollView(
                    controller: _categoryScrollController, // Giữ vị trí scroll khi chọn danh mục
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(categories.length, (index) {
                        final category = categories[index];
                        final isSelected = _selectedCategoryIndex == index;
                        return GestureDetector(
                          onTap: () async {
                            // Lưu lại vị trí scroll hiện tại
                            final currentOffset = _categoryScrollController.offset;
                            setState(() {
                              _selectedCategoryIndex = index;
                              selectedCategoryId = category['id'];
                            });
                            await loadProductsByCategory(selectedCategoryId!);
                            // Phục hồi lại vị trí scroll
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_categoryScrollController.hasClients) {
                                _categoryScrollController.jumpTo(currentOffset);
                              }
                            });
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.grey[100] : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                bottom: BorderSide(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: isSelected ? 28 : 25,
                                  backgroundImage: category['image'] != null &&
                                          category['image'].isNotEmpty
                                      ? NetworkImage(category['image'])
                                      : const AssetImage('assets/images/danh_muc.png')
                                          as ImageProvider,
                                  backgroundColor: Colors.grey[200],
                                  child: category['image'] == null ||
                                          category['image'].isEmpty
                                      ? const Icon(Icons.image_not_supported, color: Colors.grey)
                                      : null,
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Text(
                                    category['name'] ?? 'N/A',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.black87,
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                // Danh sách sản phẩm
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: product['image'] != null &&
                                product['image'].isNotEmpty
                            ? Image.network(
                                product['image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      'assets/images/san_pham.png',
                                      width: 50,
                                      height: 50,
                                    ),
                              )
                            : Image.asset(
                                'assets/images/san_pham.png',
                                width: 50,
                                height: 50,
                              ),
                        title: Text(
                          product['name'] ?? '',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        subtitle: Text(
                          product['description'] ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              product['ProDetails'] != null &&
                                      product['ProDetails'].isNotEmpty
                                  ? '${product['ProDetails'][0]['price']} đ'
                                  : 'N/A',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              product['status'] ?? 'CÒN HÀNG',
                              style: TextStyle(
                                color: product['status'] == 'HẾT HÀNG'
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                productId: product['id'],
                                // Có thể truyền thêm name, image, description nếu muốn load nhanh
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}