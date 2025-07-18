import 'package:app_selldrinks/models/product.dart';

class ProductDetail {
  final int id;
  final String name;
  final int productId;
  final int sizeId;
  final int? storeId;
  final int? buyturn;
  final String? specification;
  final int price;
  final int? oldprice;
  final int quantity;
  final String? img1;
  final String? img2;
  final String? img3;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductDetail({
    required this.id,
    required this.name,
    required this.productId,
    required this.sizeId,
    this.storeId,
    this.buyturn,
    this.specification,
    required this.price,
    this.oldprice,
    required this.quantity,
    this.img1,
    this.img2,
    this.img3,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      productId:
          json['product_id'] is int
              ? json['product_id']
              : int.tryParse(json['product_id'].toString()) ?? 0,
      sizeId:
          json['size_id'] is int
              ? json['size_id']
              : int.tryParse(json['size_id'].toString()) ?? 0,
      storeId:
          json['store_id'] != null
              ? (json['store_id'] is int
                  ? json['store_id']
                  : int.tryParse(json['store_id'].toString()))
              : null,
      buyturn:
          json['buyturn'] != null
              ? (json['buyturn'] is int
                  ? json['buyturn']
                  : int.tryParse(json['buyturn'].toString()))
              : null,
      specification: json['specification']?.toString(),
      price:
          json['price'] is int
              ? json['price']
              : int.tryParse(json['price'].toString()) ?? 0,
      oldprice:
          json['oldprice'] != null
              ? (json['oldprice'] is int
                  ? json['oldprice']
                  : int.tryParse(json['oldprice'].toString()))
              : null,
      quantity:
          json['quantity'] is int
              ? json['quantity']
              : int.tryParse(json['quantity'].toString()) ?? 0,
      img1: json['img1']?.toString(),
      img2: json['img2']?.toString(),
      img3: json['img3']?.toString(),
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null,
    );
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// for (var size in _sizes) {
//   size['size_name'] = getSizeName(size['size_id']);
// } => xuất danh sách size
