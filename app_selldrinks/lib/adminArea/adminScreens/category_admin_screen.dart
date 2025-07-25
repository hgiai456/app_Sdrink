import 'package:flutter/material.dart';
import 'package:app_selldrinks/adminArea/adminModels/category_admin.dart';
import 'package:app_selldrinks/adminArea/adminSevices/category_admin_service.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';

class CategoryAdminScreen extends StatefulWidget {
  final String token;
  const CategoryAdminScreen({Key? key, required this.token}) : super(key: key);

  @override
  _CategoryAdminScreenState createState() => _CategoryAdminScreenState();
}

class _CategoryAdminScreenState extends State<CategoryAdminScreen> {
  int currentPage = 1;
  int totalPage = 1;
  List<CategoryAdmin> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllCategories();
  }

  Future<void> fetchAllCategories({int page = 1}) async {
    setState(() => isLoading = true);
    try {
      final result = await CategoryAdminService.fetchCategories(
        widget.token,
        page,
      );
      categories = result['categories'];
      currentPage = result['currentPage'];
      totalPage = result['totalPage'];
    } catch (e) {
      // Xử lý lỗi
    }
    setState(() => isLoading = false);
  }

  void showCategoryDialog({CategoryAdmin? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final imageController = TextEditingController(text: category?.image ?? '');
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
                      category == null ? 'Thêm danh mục' : 'Sửa danh mục',
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
                        labelText: 'Tên danh mục',
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
                            final newCategory = CategoryAdmin(
                              id: category?.id,
                              name: nameController.text,
                              image: imageController.text,
                            );
                            bool success = false;
                            if (category == null) {
                              success = await CategoryAdminService.addCategory(
                                newCategory,
                                widget.token,
                              );
                            } else {
                              success =
                                  await CategoryAdminService.updateCategory(
                                    newCategory,
                                    widget.token,
                                  );
                            }
                            if (success) {
                              Navigator.pop(context);
                              fetchAllCategories(page: currentPage);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    category == null
                                        ? 'Thêm danh mục thất bại!'
                                        : 'Cập nhật danh mục thất bại!',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(category == null ? 'Thêm' : 'Cập nhật'),
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

  Future<void> deleteCategory(int id) async {
    await CategoryAdminService.deleteCategory(id, widget.token);
    fetchAllCategories(page: currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý danh mục', style: TextStyle(color: kDarkGray)),
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
                        categories.isEmpty
                            ? Center(
                              child: Text(
                                'Không có danh mục nào!',
                                style: TextStyle(color: kMediumGray),
                              ),
                            )
                            : ListView.builder(
                              itemCount: categories.length,
                              itemBuilder: (_, i) {
                                final c = categories[i];
                                return Card(
                                  color: kWhite,
                                  child: ListTile(
                                    leading:
                                        (c.image != null && c.image!.isNotEmpty)
                                            ? Image.network(
                                              c.image!,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            )
                                            : Icon(
                                              Icons.image_not_supported,
                                              color: kMediumGray,
                                            ),
                                    title: Text(
                                      c.name,
                                      style: TextStyle(color: kDarkGray),
                                    ),
                                    subtitle:
                                        c.createdAt != null
                                            ? Text(
                                              'Tạo: ${c.createdAt}',
                                              style: TextStyle(
                                                color: kMediumGray,
                                              ),
                                            )
                                            : null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: kDarkGray,
                                          ),
                                          onPressed:
                                              () => showCategoryDialog(
                                                category: c,
                                              ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => deleteCategory(c.id!),
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
        onPressed: () => showCategoryDialog(),
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
                  ? () => fetchAllCategories(page: currentPage - 1)
                  : null,
        ),
        ...pages,
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed:
              currentPage < totalPage
                  ? () => fetchAllCategories(page: currentPage + 1)
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
            page == currentPage ? null : () => fetchAllCategories(page: page),
        child: Text('$page'),
      ),
    );
  }
}
