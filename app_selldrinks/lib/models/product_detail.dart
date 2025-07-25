import 'package:app_selldrinks/models/product.dart';
import 'package:app_selldrinks/models/size.dart';

class ProductDetail {
  final int id;
  final String name;
  final int productId;
  final int sizeId;
  final int storeId;
  final int buyturn;
  final String specification;
  final int price;
  final int? oldprice; // Nullable
  final int quantity;
  final String? img1;
  final String? img2;
  final String? img3;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Product? product;
  final Size? size;

  ProductDetail({
    required this.id,
    required this.name,
    required this.productId,
    required this.sizeId,
    required this.storeId,
    required this.buyturn,
    required this.specification,
    required this.price,
    this.oldprice,
    required this.quantity,
    this.img1,
    this.img2,
    this.img3,
    required this.createdAt,
    required this.updatedAt,
    this.product,
    this.size,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing ProductDetail JSON: $json');

      return ProductDetail(
        id: _parseIntSafely(json['id']),
        name: json['name']?.toString() ?? '',
        productId: _parseIntSafely(json['product_id']),
        sizeId: _parseIntSafely(json['size_id']),
        storeId: _parseIntSafely(json['store_id']),
        buyturn: _parseIntSafely(json['buyturn'] ?? 0),
        specification: json['specification']?.toString() ?? '',
        price: _parseIntSafely(json['price']),
        oldprice:
            json['oldprice'] != null ? _parseIntSafely(json['oldprice']) : null,
        quantity: _parseIntSafely(json['quantity'] ?? 0),
        img1: _parseStringSafely(json['img1']),
        img2: _parseStringSafely(json['img2']),
        img3: _parseStringSafely(json['img3']),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        product:
            json['product'] != null ? Product.fromJson(json['product']) : null,
        size: json['sizes'] != null ? Size.fromJson(json['sizes']) : null,
      );
    } catch (e, stackTrace) {
      print('Error parsing ProductDetail from JSON: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  // Helper method để parse int an toàn
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Helper method để parse string an toàn
  static String? _parseStringSafely(dynamic value) {
    if (value == null) return null;
    if (value is String && value.trim().isEmpty) return null;
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'product_id': productId,
      'size_id': sizeId,
      'store_id': storeId,
      'buyturn': buyturn,
      'specification': specification,
      'price': price,
      'oldprice': oldprice,
      'quantity': quantity,
      'img1': img1,
      'img2': img2,
      'img3': img3,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'product': product?.toJson(),
      'sizes': size?.toJson(),
    };
  }

  // Getter để lấy image URL
  String get imageUrl {
    // Ưu tiên image từ product
    if (product?.imageUrl.isNotEmpty == true) {
      return product!.imageUrl;
    }
    // Fallback về img1, img2, img3
    if (img1?.isNotEmpty == true) return img1!;
    if (img2?.isNotEmpty == true) return img2!;
    if (img3?.isNotEmpty == true) return img3!;
    return '';
  }

  @override
  String toString() {
    return 'ProductDetail{id: $id, name: $name, price: $price, imageUrl: $imageUrl}';
  }
}
