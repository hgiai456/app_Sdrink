class ProductSimple {
  final int id;
  final String name;
  final String? imageUrl;

  ProductSimple({required this.id, required this.name, this.imageUrl});

  factory ProductSimple.fromJson(Map<String, dynamic> json) {
    try {
      return ProductSimple(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        name: json['name']?.toString() ?? '',
        imageUrl: json['image']?.toString(),
      );
    } catch (e) {
      print('Error parsing ProductSimple from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image': imageUrl};
  }

  @override
  String toString() {
    return 'ProductSimple{id: $id, name: $name, imageUrl: $imageUrl}';
  }
}
