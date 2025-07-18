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
  int currentPage = 1;
  int totalPage = 1;
  List<ProductAdmin> products = [];
  bool isLoading = true;
  List<CategoryAdmin> categories = [];

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
    fetchCategories();
  }

  Future<void> fetchAllProducts({int page = 1}) async {
    setState(() => isLoading = true);
    try {
      final result = await ProductAdminService.fetchProducts(
        widget.token,
        page,
      );
      products = result['products'];
      currentPage = result['currentPage'];
      totalPage = result['totalPage'];
    } catch (e) {
      // Xử lý lỗi
    }
    setState(() => isLoading = false);
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
    } catch (e) {}
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
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
                        labelText: 'Tên',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                      ),
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
                              image: imageController.text,
                              categoryId: selectedCategoryId,
                            );
                            bool success = false;
                            if (product == null) {
                              success = await ProductAdminService.addProduct(
                                newProduct,
                                widget.token,
                              );
                            } else {
                              success = await ProductAdminService.updateProduct(
                                newProduct,
                                widget.token,
                              );
                            }
                            if (success) {
                              Navigator.pop(context);
                              fetchAllProducts(page: currentPage);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    product == null
                                        ? 'Thêm sản phẩm thất bại!'
                                        : 'Cập nhật sản phẩm thất bại!',
                                  ),
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
    );
  }

  Future<void> deleteProduct(int id) async {
    await ProductAdminService.deleteProduct(id, widget.token);
    fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sản phẩm', style: TextStyle(color: kDarkGray)),
        backgroundColor: kWhite,
        iconTheme: IconThemeData(color: kDarkGray),
      ),
      backgroundColor: kLightGray,
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: kDarkGray))
              : Column(
                children: [
                  Expanded(
                    child:
                        products.isEmpty
                            ? Center(
                              child: Text(
                                'Không có sản phẩm nào!',
                                style: TextStyle(color: kMediumGray),
                              ),
                            )
                            : ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (_, i) {
                                final p = products[i];
                                return Card(
                                  color: kWhite,
                                  child: ListTile(
                                    leading:
                                        (p.image != null && p.image!.isNotEmpty)
                                            ? Image.network(p.image!)
                                            : Icon(
                                              Icons.image_not_supported,
                                              color: kMediumGray,
                                            ),
                                    title: Text(
                                      p.name,
                                      style: TextStyle(color: kDarkGray),
                                    ),
                                    subtitle: Text(
                                      p.description,
                                      style: TextStyle(color: kMediumGray),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: kDarkGray,
                                          ),
                                          onPressed:
                                              () =>
                                                  showProductDialog(product: p),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => deleteProduct(p.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                  buildPagination(),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showProductDialog(),
        child: Icon(Icons.add, color: kWhite),
        backgroundColor: kDarkGray,
      ),
    );
  }

  Widget buildPagination() {
    List<Widget> pages = [];
    int start = (currentPage - 2 > 0) ? currentPage - 2 : 1;
    int end = (currentPage + 2 < totalPage) ? currentPage + 2 : totalPage;

    if (start > 1) {
      pages.add(pageButton(1));
      if (start > 2) pages.add(Text('...'));
    }
    for (int i = start; i <= end; i++) {
      pages.add(pageButton(i));
    }
    if (end < totalPage) {
      if (end < totalPage - 1) pages.add(Text('...'));
      pages.add(pageButton(totalPage));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed:
              currentPage > 1
                  ? () => fetchAllProducts(page: currentPage - 1)
                  : null,
        ),
        ...pages,
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed:
              currentPage < totalPage
                  ? () => fetchAllProducts(page: currentPage + 1)
                  : null,
        ),
      ],
    );
  }

  Widget pageButton(int page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: page == currentPage ? Colors.blue : Colors.white,
          foregroundColor: page == currentPage ? Colors.white : Colors.black,
          minimumSize: Size(36, 36),
          padding: EdgeInsets.zero,
        ),
        onPressed:
            page == currentPage ? null : () => fetchAllProducts(page: page),
        child: Text('$page'),
      ),
    );
  }
}
