class ProductAdmin {
  final int? id;
  final String name;
  final String description;
  final String? image;
  final int? categoryId;
  final List<dynamic>? proDetails;

  ProductAdmin({
    this.id,
    required this.name,
    required this.description,
    this.image,
    this.categoryId,
    this.proDetails,
  });

  factory ProductAdmin.fromJson(Map<String, dynamic> json) {
    return ProductAdmin(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      categoryId: json['category_id'],
      proDetails: json['ProDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'description': description,
      'image': image,
      'category_id': categoryId,
    };
    if (proDetails != null) {
      data['ProDetails'] = proDetails;
    }
    return data;
  }
}
