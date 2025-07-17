import 'package:app_selldrinks/models/user.dart';
import 'package:app_selldrinks/screens/login_Screen.dart';
import 'package:app_selldrinks/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:app_selldrinks/components/customTextField.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _addressController =
      TextEditingController(); // Thêm controller cho address

  final _formKey = GlobalKey<FormState>();
  final UserService _authService = UserService();
  bool _isLoading = false;

  // Hàm validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email không bắt buộc
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  // Hàm validate phone (không bắt buộc)
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone không bắt buộc
    }
    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
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

  //Hàm xác nhận mật khẩu
  String? _validateComfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    //Tạo Object User
    final user = User(
      email:
          _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
      phone:
          _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      address:
          _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(), // Thêm address
    );

    final result = await _authService.register(user);

    if (result['success']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đăng ký thành công!")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${result['error']}')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Tạo tài khoản',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF383838),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đăng ký để trải nghiệm GH Coffee',
                  style: TextStyle(fontSize: 16, color: Color(0xFF808080)),
                ),
                const SizedBox(height: 40),

                // Thông tin cá nhân
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFF808080)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin cá nhân',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF383838),
                        ),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        hintText: 'Họ và tên *',
                        controller: _nameController,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Vui lòng nhập họ tên'
                                    : null,
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Color(0xFF808080),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              hintText: 'Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Color(0xFF808080),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              hintText: 'Số điện thoại',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: _validatePhone,
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: Color(0xFF808080),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        hintText: 'Địa chỉ (tuỳ chọn)',
                        controller: _addressController,
                        keyboardType: TextInputType.streetAddress,
                        maxLines: 2,
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF808080),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Mật khẩu
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFF808080)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mật khẩu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF383838),
                        ),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        hintText: 'Mật khẩu *',
                        controller: _passwordController,
                        isPassword: true,
                        validator: _validatePassword,
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Color(0xFF808080),
                        ),
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        hintText: 'Xác nhận mật khẩu *',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        validator: _validateComfirmPassword,
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Color(0xFF808080),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF383838),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Tạo tài khoản',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Color(0xFF808080), thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Hoặc đăng ký bằng',
                        style: TextStyle(
                          color: Color(0xFF808080),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Color(0xFF808080), thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Facebook
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement Facebook login
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(0xFF808080)),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF808080),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logofb.png',
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Google
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement Google login
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(0xFF808080)),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF808080),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logogg.png',
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đã có tài khoản? ',
                      style: TextStyle(color: Color(0xFF808080), fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          color: Color(0xFF383838),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
