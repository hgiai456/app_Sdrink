class Size {
  final int id;
  final String name;

  Size({required this.id, required this.name});

  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  String toString() {
    return 'Size{id: $id, name: $name}';
  }
}
