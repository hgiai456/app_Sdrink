class Store {
  final String id;
  final String name;
  final String address;
  final String district;
  final String phone;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.phone,
  });

  String get fullAddress => '$address\n$district\n$phone';
}
