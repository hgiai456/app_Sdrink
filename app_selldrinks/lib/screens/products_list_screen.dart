import 'package:app_selldrinks/components/product_item.dart';
import 'package:app_selldrinks/models/product.dart';
import 'package:app_selldrinks/screens/home_screen.dart';
import 'package:app_selldrinks/screens/prod_detail_screen.dart';
import 'package:app_selldrinks/services/product_service.dart';
import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const ProductListScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<StatefulWidget> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      List<Product> fetchedProducts;

      if (widget.categoryId != null) {
        // Nếu có categoryId, lọc sản phẩm theo category
        fetchedProducts = await ProductService.getProductsByCategory(
          widget.categoryId!,
        );
      } else {
        // Nếu không có categoryId, lấy tất cả sản phẩm
        fetchedProducts = await ProductService.getProducts();
      }

      print("Sản phẩm từ API: $fetchedProducts");
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi load sản phẩm: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(Icons.close, color: Color(0xFF383838), size: 20),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ),
        title: Text(
          widget.categoryName ?? "Tất cả sản phẩm",
          style: TextStyle(
            color: Color(0xFF383838),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: Color(0xFF383838), size: 20),
              onPressed: () {
                //Xử lý sự kiện click
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter và Layout Controls
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF808080).withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFFF5F5F5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune, size: 18, color: Color(0xFF383838)),
                      SizedBox(width: 6),
                      Text(
                        'Lọc',
                        style: TextStyle(
                          color: Color(0xFF383838),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF808080).withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFFF5F5F5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.apps, size: 18, color: Color(0xFF383838)),
                      SizedBox(width: 6),
                      Text(
                        'Grid',
                        style: TextStyle(
                          color: Color(0xFF383838),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Product Count
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${products.length} sản phẩm',
                  style: TextStyle(
                    color: Color(0xFF808080),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child:
                isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF383838),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Đang tải sản phẩm...',
                            style: TextStyle(
                              color: Color(0xFF808080),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : products.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 48,
                              color: Color(0xFF808080),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có sản phẩm nào',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF383838),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.categoryName != null
                                ? 'Danh mục "${widget.categoryName}" chưa có sản phẩm'
                                : 'Hãy thêm sản phẩm mới',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF808080),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ProductItem(
                            product: products[index],
                            onTap: () {
                              //Xử lý sự kiện khi nhấn vào 1 product trong Product_list_screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailScreen(
                                        productId: products[index].id,
                                      ),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã chọn ${products[index].name}',
                                  ),
                                  backgroundColor: Color(0xFF383838),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomSheet: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Color(0xFF383838),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
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
            const SizedBox(width: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.location_on, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mang Về',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
