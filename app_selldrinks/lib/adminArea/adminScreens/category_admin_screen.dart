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
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  int totalPage = 1;
  List<CategoryAdmin> categories = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchAllCategories(refresh: true);
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
        loadMoreCategories();
      }
    }
  }

  Future<void> fetchAllCategories({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        categories.clear();
        hasMoreData = true;
      });
    }

    try {
      final result = await CategoryAdminService.fetchCategories(
        widget.token,
        currentPage,
      );

      setState(() {
        if (refresh) {
          categories = result['categories'];
        } else {
          categories.addAll(result['categories']);
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

  Future<void> loadMoreCategories() async {
    if (currentPage >= totalPage) return;

    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    await fetchAllCategories();
  }

  Future<void> _refreshData() async {
    await fetchAllCategories(refresh: true);
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
              padding: const EdgeInsets.all(24),
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
                              image:
                                  imageController.text.isEmpty
                                      ? null
                                      : imageController.text,
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
                              _refreshData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    category == null
                                        ? '✅ Thêm danh mục thành công!'
                                        : '✅ Cập nhật danh mục thành công!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    category == null
                                        ? '❌ Thêm danh mục thất bại!'
                                        : '❌ Cập nhật danh mục thất bại!',
                                  ),
                                  backgroundColor: Colors.red,
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

  Future<void> deleteCategory(CategoryAdmin category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa danh mục "${category.name}"?',
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
      final success = await CategoryAdminService.deleteCategory(
        category.id!,
        widget.token,
      );
      if (success) {
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Xóa danh mục thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Xóa danh mục thất bại!'),
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
        title: Text('Quản lý danh mục', style: TextStyle(color: kDarkGray)),
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
                : categories.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category, size: 64, color: kMediumGray),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có danh mục nào!',
                        style: TextStyle(
                          fontSize: 18,
                          color: kMediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhấn nút + để thêm danh mục mới',
                        style: TextStyle(color: kMediumGray),
                      ),
                    ],
                  ),
                )
                : LayoutBuilder(
                  builder: (context, constraints) {
                    // ✅ TÍNH TOÁN DYNAMIC CROSS AXIS COUNT DỰA TRÊN SCREEN WIDTH
                    int crossAxisCount = 2;
                    if (constraints.maxWidth > 600) {
                      crossAxisCount = 3;
                    } else if (constraints.maxWidth > 400) {
                      crossAxisCount = 2;
                    } else {
                      crossAxisCount = 1;
                    }

                    // ✅ TÍNH TOÁN CHILD ASPECT RATIO ĐỂ TRÁNH OVERFLOW
                    double childAspectRatio = 0.75;
                    if (constraints.maxWidth < 400) {
                      childAspectRatio = 1.2;
                    }

                    return GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12), // ✅ GIẢM PADDING
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 8, // ✅ GIẢM SPACING
                        mainAxisSpacing: 8, // ✅ GIẢM SPACING
                        childAspectRatio: childAspectRatio, // ✅ DYNAMIC RATIO
                      ),
                      itemCount:
                          categories.length +
                          (isLoadingMore ? crossAxisCount : 0),
                      itemBuilder: (context, index) {
                        // ✅ LOADING INDICATORS
                        if (index >= categories.length) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: kDarkGray,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        final category = categories[index];
                        return Card(
                          color: kWhite,
                          elevation: 2, // ✅ GIẢM ELEVATION
                          margin: const EdgeInsets.all(2), // ✅ GIẢM MARGIN
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ✅ IMAGE CONTAINER VỚI FIXED HEIGHT
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: kLightGray,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    child:
                                        category.image != null &&
                                                category.image!.isNotEmpty
                                            ? Image.network(
                                              category.image!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => _buildDefaultImage(),
                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: kDarkGray,
                                                        strokeWidth: 2,
                                                      ),
                                                );
                                              },
                                            )
                                            : _buildDefaultImage(),
                                  ),
                                ),
                                // ✅ CONTENT AREA VỚI CONSTRAINED HEIGHT
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      8,
                                    ), // ✅ GIẢM PADDING
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize:
                                          MainAxisSize.min, // ✅ IMPORTANT!
                                      children: [
                                        // ✅ FLEXIBLE TEXT VỚI PROPER CONSTRAINTS
                                        Flexible(
                                          child: Text(
                                            category.name,
                                            style: TextStyle(
                                              color: kDarkGray,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12, // ✅ GIẢM FONT SIZE
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Spacer(),
                                        // ✅ CONSTRAINED BUTTON ROW
                                        SizedBox(
                                          height: 32, // ✅ FIXED HEIGHT
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Flexible(
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: kDarkGray,
                                                    size:
                                                        18, // ✅ GIẢM ICON SIZE
                                                  ),
                                                  onPressed:
                                                      () => showCategoryDialog(
                                                        category: category,
                                                      ),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                ),
                                              ),
                                              Flexible(
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                    size:
                                                        18, // ✅ GIẢM ICON SIZE
                                                  ),
                                                  onPressed:
                                                      () => deleteCategory(
                                                        category,
                                                      ),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCategoryDialog(),
        backgroundColor: kDarkGray,
        child: Icon(Icons.add, color: kWhite),
        tooltip: 'Thêm danh mục mới',
      ),
    );
  }

  // ✅ HELPER METHOD CHO DEFAULT IMAGE
  Widget _buildDefaultImage() {
    return Container(
      color: kLightGray,
      child: Icon(
        Icons.category,
        size: 36, // ✅ RESPONSIVE ICON SIZE
        color: kMediumGray,
      ),
    );
  }
}
