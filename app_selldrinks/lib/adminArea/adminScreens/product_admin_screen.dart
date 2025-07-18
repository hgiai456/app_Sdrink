import 'package:flutter/material.dart';
import 'package:app_selldrinks/adminArea/adminModels/product_admin.dart';
import 'package:app_selldrinks/adminArea/adminSevices/product_admin_service.dart';

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

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
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

  void showProductDialog({ProductAdmin? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController = TextEditingController(
      text: product?.description ?? '',
    );
    final imageController = TextEditingController(text: product?.image ?? '');
    final brandIdController = TextEditingController(
      text: product?.brandId?.toString() ?? '',
    );
    final categoryIdController = TextEditingController(
      text: product?.categoryId?.toString() ?? '',
    );
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Tên'),
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Không được để trống'
                                  : null,
                    ),
                    TextFormField(
                      controller: descController,
                      decoration: InputDecoration(labelText: 'Mô tả'),
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Không được để trống'
                                  : null,
                    ),
                    TextFormField(
                      controller: imageController,
                      decoration: InputDecoration(labelText: 'Ảnh (URL)'),
                    ),
                    TextFormField(
                      controller: brandIdController,
                      decoration: InputDecoration(labelText: 'Brand ID'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: categoryIdController,
                      decoration: InputDecoration(labelText: 'Category ID'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final newProduct = ProductAdmin(
                    id: product?.id,
                    name: nameController.text,
                    description: descController.text,
                    image: imageController.text,
                    brandId: int.tryParse(brandIdController.text),
                    categoryId: int.tryParse(categoryIdController.text),
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
    );
  }

  Future<void> deleteProduct(int id) async {
    await ProductAdminService.deleteProduct(id, widget.token);
    fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý sản phẩm')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child:
                        products.isEmpty
                            ? Center(child: Text('Không có sản phẩm nào!'))
                            : ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (_, i) {
                                final p = products[i];
                                return ListTile(
                                  leading:
                                      (p.image != null && p.image!.isNotEmpty)
                                          ? Image.network(p.image!)
                                          : Icon(Icons.image_not_supported),
                                  title: Text(p.name),
                                  subtitle: Text(p.description),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed:
                                            () => showProductDialog(product: p),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () => deleteProduct(p.id!),
                                      ),
                                    ],
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
        child: Icon(Icons.add),
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
