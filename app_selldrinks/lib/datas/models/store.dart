class Store {
  final String id;
  final String name;
  final String address;
  final String district;
  final String phone;
  final String image;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.phone,
    required this.image,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'].toString(),
      name: json['storeName'] ?? '',
      address: json['address'] ?? '',
      district: '', // API không có, bạn có thể map nếu cần
      phone: json['phoneNumber'] ?? '',
      image: json['image'] ?? '',
    );
  }

  String get fullAddress => '$address\n$district\n$phone';
}
