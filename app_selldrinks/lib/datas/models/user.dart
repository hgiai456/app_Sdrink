class User {
  final String? email;
  final String? phone;
  final String password;
  final String name;
  final String? address;

  User({
    this.email,
    this.phone,
    required this.password,
    required this.name,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'password': password,
      'name': name,
      'address': address?.isEmpty ?? true ? null : address,
    };
  }
}
