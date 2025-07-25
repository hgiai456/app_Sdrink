import 'package:app_selldrinks/models/simple_product_detail.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int? brandId;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SimpleProductDetail>? productDetails; // Thay đổi type

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.brandId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.productDetails,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing Product: ${json['name']}');
      print('Product details: ${json['product_details']}');

      return Product(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        imageUrl: json['image']?.toString() ?? '',
        brandId:
            json['brand_id'] != null
                ? (json['brand_id'] is int
                    ? json['brand_id']
                    : int.parse(json['brand_id'].toString()))
                : null,
        categoryId:
            json['category_id'] is int
                ? json['category_id']
                : int.parse(json['category_id'].toString()),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        // Parse product_details với SimpleProductDetail
        productDetails:
            json['product_details'] != null
                ? (json['product_details'] as List).map((detail) {
                  print('Parsing product detail: $detail');
                  return SimpleProductDetail.fromJson(detail);
                }).toList()
                : null,
      );
    } catch (e, stackTrace) {
      print('Error parsing Product from JSON: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': imageUrl,
      'brand_id': brandId,
      'category_id': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'product_details':
          productDetails?.map((detail) => detail.toJson()).toList(),
    };
  }

  // Getter để lấy giá thấp nhất từ product_details
  int? get minPrice {
    if (productDetails == null || productDetails!.isEmpty) return null;
    return productDetails!
        .map((detail) => detail.price)
        .reduce((a, b) => a < b ? a : b);
  }

  // Getter để lấy giá cao nhất từ product_details
  int? get maxPrice {
    if (productDetails == null || productDetails!.isEmpty) return null;
    return productDetails!
        .map((detail) => detail.price)
        .reduce((a, b) => a > b ? a : b);
  }

  // Getter để hiển thị price range
  String get priceRange {
    if (productDetails == null || productDetails!.isEmpty) {
      return 'Liên hệ';
    }

    final min = minPrice!;
    final max = maxPrice!;

    if (min == max) {
      return '${_formatPrice(min)}đ';
    } else {
      return '${_formatPrice(min)}đ - ${_formatPrice(max)}đ';
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, imageUrl: $imageUrl, priceRange: $priceRange}';
  }
}
