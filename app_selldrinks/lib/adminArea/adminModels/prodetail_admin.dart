class ProdetailAdmin {
  final int? id;
  final String name;
  final int productId;
  final int sizeId;
  final int storeId;
  final int price;
  final int? oldprice;
  final int quantity;
  final String? specification;
  final String? img1;
  final String? img2;
  final String? img3;
  final DateTime? createdAt;

  ProdetailAdmin({
    this.id,
    required this.name,
    required this.productId,
    required this.sizeId,
    this.storeId = 1,
    required this.price,
    this.oldprice,
    required this.quantity,
    this.specification,
    this.img1,
    this.img2,
    this.img3,
    this.createdAt,
  });

  factory ProdetailAdmin.fromJson(Map<String, dynamic> json) {
    return ProdetailAdmin(
      id: json['id'],
      name: json['name'] ?? '',
      productId: json['product_id'],
      sizeId: json['size_id'],
      storeId: json['store_id'] ?? 1,
      price: json['price'],
      oldprice: json['oldprice'],
      quantity: json['quantity'],
      specification: json['specification'],
      img1: json['img1'],
      img2: json['img2'],
      img3: json['img3'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'product_id': productId,
      'size_id': sizeId,
      'store_id': 1,
      'price': price,
      'oldprice': oldprice,
      'quantity': quantity,
      'specification': specification,
      'img1': img1,
      'img2': img2,
      'img3': img3,
    };
  }
}
