class ProductAdmin {
  final int? id;
  final String name;
  final String description;
  final String? image;
  final int? brandId;
  final int? categoryId;
  final List<dynamic>? proDetails;

  ProductAdmin({
    this.id,
    required this.name,
    required this.description,
    this.image,
    this.brandId,
    this.categoryId,
    this.proDetails,
  });

  factory ProductAdmin.fromJson(Map<String, dynamic> json) {
    return ProductAdmin(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      brandId: json['brand_id'],
      categoryId: json['category_id'],
      proDetails: json['ProDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'description': description,
      'image': image,
      'brand_id': brandId,
      'category_id': categoryId,
    };
    // Chỉ thêm ProDetails nếu nó khác null và dùng cho update, không dùng cho add
    if (proDetails != null) {
      data['ProDetails'] = proDetails;
    }
    return data;
  }
}
