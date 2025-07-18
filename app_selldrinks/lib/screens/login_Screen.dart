import 'package:app_selldrinks/screens/home_screen.dart';
import 'package:app_selldrinks/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_selldrinks/services/user_service.dart';
import 'package:app_selldrinks/models/loginuser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  // Tạo STF cho màn hình dn để có thể thay đổi trạng thái
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //Controller để quản lý text input
  final UserService _userService = UserService();
  final TextEditingController _emailController = TextEditingController();
  //tạo controller cho input email
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  //tạo biến boolean để lưu trạng thái
  bool _obscurePassword = true;

  // Thêm hàm xử lý đăng nhập
  Future<void> _handleLogin() async {
    String input = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')));
      return;
    }

    // Kiểm tra input là email hay số điện thoại
    LoginUser loginUser;
    if (RegExp(r'^[0-9]{9,}$').hasMatch(input)) {
      // Là số điện thoại
      loginUser = LoginUser(phone: input, password: password);
    } else {
      // Là email
      loginUser = LoginUser(email: input, password: password);
    }

    final result = await _userService.login(loginUser);

    if (result['success']) {
      String token = result['token'];
      // Lưu token vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      // Chuyển sang HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Đăng nhập thất bại')),
      );
    }
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
                  color: Color(0xFF383838),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: _emailController, //gán controller để qly
                decoration: InputDecoration(
                  hintText: 'Email hoặc số điện thoại',
                  hintStyle: TextStyle(color: Color(0xFF808080)), // chữ mờ
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // bo góc 8px
                    borderSide: BorderSide(
                      color: Color(0xFF80880), // màu viền
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // viền khi enabled nhưng không focus
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xFF808080),
                    ), // màu viền khi focus
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Color(0xFF383838), // màu viền khi focus
                    ),
                  ),

                  contentPadding: EdgeInsets.symmetric(
                    //Pađing bên trong ô input
                    vertical: 16, // khoảng cách trên dưới
                    horizontal: 16, // khoảng cách trái phải
                  ),
                ),
              ),

              SizedBox(height: 16),

              //Ô nhập mật khẩu
              TextField(
                controller: _passwordController, // Controller cho mật khẩu
                obscureText:
                    _obscurePassword, // Ẩn/hiện mật khẩu dựa vào biến boolean
                decoration: InputDecoration(
                  hintText: 'Mật Khẩu',
                  hintStyle: TextStyle(color: Color(0xFF808080)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF808080)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF808080)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF383838)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),

                  //ICON con mắt để Ẩn / hiện mk
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Color(0xFF808080),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                        //  Thay đổi trạng thái ẩn/hiện mật khẩu
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),

              //Hàng chứa checkbox "Ghi nhớ tôi" và link "Quên mật khẩu"
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, //Căn 2 đầu (sẽ ở giữa)
                children: [
                  Row(
                    children: [
                      //Phần bên trái :checkbox + text
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              //Cập nhật trạng thái khi checkbox thay đổi
                              setState(() {
                                _rememberMe =
                                    value ?? false; //nếu null thì gán false
                              });
                            },
                            activeColor:
                                Theme.of(context).primaryColor, //màu dc chọn
                          ),
                          Text(
                            'Ghi nhớ tôi',
                            style: TextStyle(
                              color: Color(0xFF808080),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 32),

              SizedBox(
                width: double.infinity, //Chiều rộng full màn hình
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Đăng nhập',
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
                    child: Divider(color: Color(0xFF808080)),
                  ), // Đường kẻ bên trái
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'hoặc',
                      style: TextStyle(color: Color(0xFF808080), fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Color(0xFF808080)),
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
                      border: Border.all(color: Color(0xFF808080)),
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
                      border: Border.all(color: Color(0xFF808080)),
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
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Tạo một tài khoản',
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
