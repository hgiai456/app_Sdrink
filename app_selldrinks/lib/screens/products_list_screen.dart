import 'package:app_selldrinks/components/product_item.dart';
import 'package:app_selldrinks/models/product.dart';
import 'package:app_selldrinks/screens/home_screen.dart';
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text(
          widget.categoryName ?? "Tất cả sản  phẩm",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium!.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              //Xử lý sự kiện click
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.tune,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.apps,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFA10F1A),
                      ),
                    )
                    : products.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có sản phẩm nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.categoryName != null
                                ? 'Danh mục "${widget.categoryName}" chưa có sản phẩm'
                                : 'Hãy thêm sản phẩm mới',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ProductItem(
                          product: products[index],
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã chọn ${products[index].name}',
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomSheet: Container(
        height: 60,
        color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mang Về',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    '35 Thang Long Tan Binh HCMC',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
