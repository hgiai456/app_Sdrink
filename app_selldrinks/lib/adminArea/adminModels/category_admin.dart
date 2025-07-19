class CategoryAdmin {
  final int? id;
  final String name;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryAdmin({
    this.id,
    required this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryAdmin.fromJson(Map<String, dynamic> json) {
    return CategoryAdmin(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'image': image};
  }
}
