class SizeAdmin {
  final int? id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SizeAdmin({this.id, required this.name, this.createdAt, this.updatedAt});

  factory SizeAdmin.fromJson(Map<String, dynamic> json) {
    return SizeAdmin(
      id: json['id'],
      name: json['name'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
