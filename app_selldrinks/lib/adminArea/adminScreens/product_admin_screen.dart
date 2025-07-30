import 'package:flutter/material.dart';
import 'package:app_selldrinks/adminArea/adminModels/product_admin.dart';
import 'package:app_selldrinks/adminArea/adminSevices/product_admin_service.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';
import 'package:app_selldrinks/adminArea/adminSevices/category_admin_service.dart';
import 'package:app_selldrinks/adminArea/adminModels/category_admin.dart';

class ProductAdminScreen extends StatefulWidget {
  final String token;
  const ProductAdminScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ProductAdminScreenState createState() => _ProductAdminScreenState();
}

class _ProductAdminScreenState extends State<ProductAdminScreen> {
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  int totalPage = 1;
  List<ProductAdmin> products = [];
  List<CategoryAdmin> categories = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchAllProducts(refresh: true);
    fetchCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMoreData) {
        loadMoreProducts();
      }
    }
  }

  Future<void> fetchAllProducts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        products.clear();
        hasMoreData = true;
      });
    }

    try {
      final result = await ProductAdminService.fetchProducts(
        widget.token,
        currentPage,
      );

      setState(() {
        if (refresh) {
          products = result['products'];
        } else {
          products.addAll(result['products']);
        }
        totalPage = result['totalPage'];
        hasMoreData = currentPage < totalPage;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
    }
  }

  Future<void> loadMoreProducts() async {
    if (currentPage >= totalPage) return;

    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    await fetchAllProducts();
  }

  Future<void> fetchCategories() async {
    try {
      final result = await CategoryAdminService.fetchCategories(
        widget.token,
        1,
      );
      setState(() {
        categories = result['categories'];
      });
    } catch (e) {
      print('Lỗi tải categories: $e');
    }
  }

  Future<void> _refreshData() async {
    await fetchAllProducts(refresh: true);
    await fetchCategories();
  }

  void showProductDialog({ProductAdmin? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController = TextEditingController(
      text: product?.description ?? '',
    );
    final imageController = TextEditingController(text: product?.image ?? '');
    int? selectedCategoryId = product?.categoryId;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: kLightGray,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: kDarkGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên sản phẩm',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: kWhite,
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Không được để trống'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: kWhite,
                        ),
                        maxLines: 3,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Không được để trống'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: imageController,
                        decoration: InputDecoration(
                          labelText: 'Ảnh (URL)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: kWhite,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'Danh mục',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: kWhite,
                        ),
                        items:
                            categories
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat.id,
                                    child: Text(cat.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          selectedCategoryId = val;
                        },
                        validator: (v) => v == null ? 'Chọn danh mục' : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                color: kMediumGray,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kDarkGray,
                              foregroundColor: kWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;

                              final newProduct = ProductAdmin(
                                id: product?.id,
                                name: nameController.text,
                                description: descController.text,
                                image:
                                    imageController.text.isEmpty
                                        ? null
                                        : imageController.text,
                                categoryId: selectedCategoryId,
                              );

                              bool success = false;
                              if (product == null) {
                                success = await ProductAdminService.addProduct(
                                  newProduct,
                                  widget.token,
                                );
                              } else {
                                success =
                                    await ProductAdminService.updateProduct(
                                      newProduct,
                                      widget.token,
                                    );
                              }

                              if (success) {
                                Navigator.pop(context);
                                _refreshData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      product == null
                                          ? '✅ Thêm sản phẩm thành công!'
                                          : '✅ Cập nhật sản phẩm thành công!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      product == null
                                          ? '❌ Thêm sản phẩm thất bại!'
                                          : '❌ Cập nhật sản phẩm thất bại!',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Text(product == null ? 'Thêm' : 'Cập nhật'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Future<void> deleteProduct(ProductAdmin product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa sản phẩm "${product.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final success = await ProductAdminService.deleteProduct(
        product.id!,
        widget.token,
      );
      if (success) {
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Xóa sản phẩm thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Xóa sản phẩm thất bại!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sản phẩm', style: TextStyle(color: kDarkGray)),
        backgroundColor: kWhite,
        iconTheme: IconThemeData(color: kDarkGray),
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: kDarkGray),
            onPressed: _refreshData,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      backgroundColor: kLightGray,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: kDarkGray,
        child:
            isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: kDarkGray),
                      const SizedBox(height: 16),
                      Text(
                        'Đang tải dữ liệu...',
                        style: TextStyle(color: kMediumGray),
                      ),
                    ],
                  ),
                )
                : products.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag, size: 64, color: kMediumGray),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có sản phẩm nào!',
                        style: TextStyle(
                          fontSize: 18,
                          color: kMediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhấn nút + để thêm sản phẩm mới',
                        style: TextStyle(color: kMediumGray),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == products.length) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(color: kDarkGray),
                      );
                    }

                    final product = products[index];
                    return Card(
                      color: kWhite,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  product.image != null &&
                                          product.image!.isNotEmpty
                                      ? Image.network(
                                        product.image!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: kLightGray,
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    color: kMediumGray,
                                                  ),
                                                ),
                                      )
                                      : Container(
                                        width: 60,
                                        height: 60,
                                        color: kLightGray,
                                        child: Icon(
                                          Icons.shopping_bag,
                                          color: kMediumGray,
                                        ),
                                      ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      color: kDarkGray,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    style: TextStyle(
                                      color: kMediumGray,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: kDarkGray,
                                          size: 20,
                                        ),
                                        onPressed:
                                            () => showProductDialog(
                                              product: product,
                                            ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () => deleteProduct(product),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showProductDialog(),
        backgroundColor: kDarkGray,
        child: Icon(Icons.add, color: kWhite),
        tooltip: 'Thêm sản phẩm mới',
      ),
    );
  }
}
