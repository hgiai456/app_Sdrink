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
          json['ProDetails'] != null &&
                  (json['ProDetails'] as List).isNotEmpty &&
                  json['ProDetails'][0]['price'] != null
              ? (json['ProDetails'][0]['price'] is int
                  ? json['ProDetails'][0]['price']
                  : int.tryParse(json['ProDetails'][0]['price'].toString()) ??
                      0)
              : 0,
      brandId: json['brand_id'] ?? 0, // Xử lý trường hợp null
      categoryId: json['category_id'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      productDetails:
          json['productDetails'] != null
              ? (json['productDetails'] as List)
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
      'productDetails':
          productDetails?.map((detail) => detail.toJson()).toList(),
    };
  }
}
