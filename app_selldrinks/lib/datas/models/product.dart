import 'package:app_selldrinks/models/product_detail.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final int? brandId;
  final int categoryId;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  final List<ProductDetail>? productDetails;
  Product({
    required this.id,
    required this.name,
    required this.description,
    this.brandId,
    required this.categoryId,
    required this.price,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.productDetails,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image'],
      price:
          json['product_details'] != null &&
                  (json['product_details'] as List).isNotEmpty &&
                  json['product_details'][0]['price'] != null
              ? (json['product_details'][0]['price'] is int
                  ? json['product_details'][0]['price']
                  : int.tryParse(
                        json['product_details'][0]['price'].toString(),
                      ) ??
                      0)
              : 0,
      brandId: json['brand_id'] ?? 0, // Xử lý trường hợp null
      categoryId: json['category_id'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      productDetails:
          json['product_details'] != null
              ? (json['product_details'] as List)
                  .map((detail) => ProductDetail.fromJson(detail))
                  .toList()
              : null,
    );
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
}
