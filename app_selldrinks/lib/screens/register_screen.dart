import 'package:app_selldrinks/screens/login_Screen.dart';
import 'package:flutter/material.dart';
import 'package:app_selldrinks/components/customTextField.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Hàm validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  // Hàm validate mật khẩu
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold : cấu trúc cơ bản cảu màn hình với appbar , body ..
      backgroundColor: Colors.white,
      body: SafeArea(
        //SafeArea đảm bảo nd k bị che bởi status bar
        child: SingleChildScrollView(
          // cho phép cuộn khi nd vượt quá màn hình
          padding: EdgeInsets.symmetric(
            //padding phải trái 24px
            horizontal: 24,
          ),
          child: Column(
            //Sắp xếp các widget theo chiều dọc
            crossAxisAlignment:
                CrossAxisAlignment.center, //căn giữa theo chiều ngang
            children: [
              SizedBox(height: 60),
              Container(
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              SizedBox(height: 40), //Khoảng cách
              Text(
                'Chào mừng bạn đến với GH Coffee',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B2B1B),
                ),
              ),
              SizedBox(height: 40),

              CustomTextField(
                hintText: 'Email/Số Điện Thoại',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                prefixIcon: Icon(Icons.email, color: Colors.grey.shade600),
                onChanged: (value) {
                  print('Email changed: $value');
                },
              ),

              SizedBox(height: 16),

              //Ô nhập mật khẩu
              //
              CustomTextField(
                hintText: 'Mật Khẩu',
                controller: _passwordController,
                isPassword: true,
                validator: _validatePassword,
                prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600),
              ),

              SizedBox(height: 16),

              CustomTextField(
                hintText: 'Nhập Mật Khẩu',
                controller: _passwordController,
                isPassword: true,
                validator: _validatePassword,
                prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600),
              ),
              SizedBox(height: 16),

              SizedBox(height: 32),

              SizedBox(
                width: double.infinity, //Chiều rộng full màn hình
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Đăng Ký',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1, //Khoảng cách giữa các chữ cái
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),

              //Dg kẻ ngang với chữ "hoặc" ở giữa
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey.shade400),
                  ), // Đường kẻ bên trái
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'hoặc',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey.shade400),
                  ), // Đường kẻ bên phải
                ],
              ),
              SizedBox(height: 32),

              //nút đăng nhập bằng mạng xh
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, //Chia đều khoản cách
                children: [
                  //nút đang nhập bằng Facebook
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logofb.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  //nút đăng nhập bằng Google
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logogg.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to login screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Đăng Nhập',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
