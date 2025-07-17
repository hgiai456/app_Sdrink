import 'package:app_selldrinks/models/category.dart';
import 'package:app_selldrinks/screens/products_list_screen.dart';
import 'package:app_selldrinks/services/category_service.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<Category> _categories = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      final categories = await CategoryService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không thể tải danh mục: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 120, child: _buildCategoryList(context));
  }

  Widget _buildCategoryList(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF383838)), // Dark Gray
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              _error,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadCategories,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text(
          'Không có danh mục nào',
          style: TextStyle(color: Color(0xFF383838), fontSize: 14), // Dark Gray
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ProductListScreen(
                      categoryId: category.id,
                      categoryName: category.name,
                    ),
              ),
            );
          },
          child: Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5), // Light Gray
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(
                        0xFF383838,
                      ).withAlpha((255 * 0.3).round()), // Dark Gray nhạt
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      category.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5), // Light Gray
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getCategoryIcon(category.name),
                            color: const Color(0xFF383838), // Dark Gray
                            size: 28,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5), // Light Gray
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF383838), // Dark Gray
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF383838), // Dark Gray
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'cà phê':
        return Icons.local_cafe;
      case 'trà sữa':
        return Icons.local_drink;
      case 'sinh tố':
        return Icons.blender;
      case 'bánh ngọt':
        return Icons.cake;
      case 'nước ép':
        return Icons.local_bar;
      case 'đồ ăn nhẹ':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }
}
