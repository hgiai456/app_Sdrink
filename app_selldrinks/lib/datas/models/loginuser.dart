// app_selldrinks/lib/models/loginuser.dart
class LoginUser {
  final String? email;
  final String? phone;
  final String password;

  LoginUser({this.email, this.phone, required this.password});

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'password': password,
    };
  }
}
