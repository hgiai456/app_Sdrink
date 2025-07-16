import 'package:app_selldrinks/models/product.dart';

class ProductDetail {
  final int id;
  final String name;
  final int productId; // Foreign key liên kết với Product
  final int sizeId;
  final int storeId;
  final int? buyturn;
  final String? specification;
  final double price;
  final double oldprice;
  final int quantity;
  final String? img1;
  final String? img2;
  final String? img3;

  // Tham chiếu đến Product (optional)
  final Product? product;

  ProductDetail({
    required this.id,
    required this.name,
    required this.productId,
    required this.sizeId,
    required this.storeId,
    this.buyturn,
    this.specification,
    required this.price,
    required this.oldprice,
    required this.quantity,
    this.img1,
    this.img2,
    this.img3,
    this.product,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'],
      name: json['name'],
      productId: json['product_id'],
      sizeId: json['size_id'],
      storeId: json['store_id'],
      buyturn: json['buyturn'],
      specification: json['specification'],
      price: json['price']?.toInt() ?? 0.0,
      oldprice: json['oldprice']?.toInt() ?? 0.0,
      quantity: json['quantity'],
      img1: json['img1'],
      img2: json['img2'],
      img3: json['img3'],
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
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
      'product': product?.toJson(),
    };
  }
}

String getSizeName(int sizeId) {
  switch (sizeId) {
    case 1:
      return 'S';
    case 2:
      return 'M';
    case 3:
      return 'L';
    default:
      return 'Khác';
  }
}


// for (var size in _sizes) {
//   size['size_name'] = getSizeName(size['size_id']);
// } => xuất danh sách size