class ProductDetailModel {
  final String message;
  final int id;
  final String name;
  final String description;
  final String image;
  final List<ProductSizeModel> sizes;

  ProductDetailModel({
    required this.message,
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.sizes,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      message: json['message'] ?? '',
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      sizes:
          (json['sizes'] as List<dynamic>? ?? [])
              .map((size) => ProductSizeModel.fromJson(size))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'sizes': sizes.map((size) => size.toJson()).toList(),
    };
  }
}

class ProductSizeModel {
  final int productDetailId;
  final int sizeId;
  final String sizeName;
  final int price;
  final int oldPrice;
  final int quantity;

  ProductSizeModel({
    required this.productDetailId,
    required this.sizeId,
    required this.sizeName,
    required this.price,
    required this.oldPrice,
    required this.quantity,
  });

  factory ProductSizeModel.fromJson(Map<String, dynamic> json) {
    return ProductSizeModel(
      productDetailId: json['product_detail_id'] ?? 0,
      sizeId: json['size_id'] ?? 0,
      sizeName: json['size_name'] ?? '',
      price: json['price'] ?? 0,
      oldPrice: json['oldprice'] ?? 0,
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_detail_id': productDetailId,
      'size_id': sizeId,
      'size_name': sizeName,
      'price': price,
      'oldprice': oldPrice,
      'quantity': quantity,
    };
  }

  // Kiểm tra có giảm giá không
  bool get hasDiscount => oldPrice > price;

  // Tính phần trăm giảm giá
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((oldPrice - price) / oldPrice * 100);
  }

  // Kiểm tra còn hàng
  bool get inStock => quantity > 0;
}
