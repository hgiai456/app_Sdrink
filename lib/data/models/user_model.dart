class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      avatar: json['avatar'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role,
    };
  }
} 