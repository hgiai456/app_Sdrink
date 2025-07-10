import 'package:flutter/material.dart';

// Custom TextField Component - Có thể tái sử dụng
class CustomTextField extends StatefulWidget {
  // Các thuộc tính có thể tùy chỉnh từ bên ngoài
  final String hintText; // Text gợi ý
  final TextEditingController? controller; // Controller để quản lý text
  final bool isPassword; // Có phải là field mật khẩu không
  final TextInputType keyboardType; // Loại bàn phím (email, số, text...)
  final String? Function(String?)? validator; // Hàm validate input
  final void Function(String)? onChanged; // Callback khi text thay đổi
  final void Function()? onTap; // Callback khi tap vào field
  final bool enabled; // Có cho phép nhập không
  final Widget? prefixIcon; // Icon bên trái
  final Widget? suffixIcon; // Icon bên phải (tùy chỉnh)
  final int maxLines; // Số dòng tối đa
  final Color? borderColor; // Màu viền
  final Color? focusedBorderColor; // Màu viền khi focus
  final double borderRadius; // Độ bo góc
  final EdgeInsetsGeometry? contentPadding; // Padding bên trong

  const CustomTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onTap,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius = 8.0,
    this.contentPadding,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  // Biến để quản lý ẩn/hiện mật khẩu
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscurePassword : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),

        // Icon bên trái
        prefixIcon: widget.prefixIcon,

        // Icon bên phải - tự động thêm icon ẩn/hiện cho password
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
                : widget.suffixIcon,

        // Padding bên trong
        contentPadding:
            widget.contentPadding ??
            EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        // Viền khi không focus
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.borderColor ?? Colors.grey.shade300,
          ),
        ),

        // Viền khi enabled nhưng không focus
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.borderColor ?? Colors.grey.shade300,
          ),
        ),

        // Viền khi focus
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? Colors.red.shade700,
            width: 2,
          ),
        ),

        // Viền khi có lỗi
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),

        // Viền khi focus và có lỗi
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
      ),
    );
  }
}
//////////////////////////////////
//Cách sử dụng :

// class ExampleUsagePage extends StatefulWidget {
//   @override
//   _ExampleUsagePageState createState() => _ExampleUsagePageState();
// }

// class _ExampleUsagePageState extends State<ExampleUsagePage> {
//   // Controllers cho các TextField
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _nameController = TextEditingController();

//   // Hàm validate email
//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Vui lòng nhập email';
//     }
//     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//       return 'Email không hợp lệ';
//     }
//     return null;
//   }

//   // Hàm validate mật khẩu
//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Vui lòng nhập mật khẩu';
//     }
//     if (value.length < 6) {
//       return 'Mật khẩu phải có ít nhất 6 ký tự';
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Custom TextField Examples'),
//         backgroundColor: Colors.red.shade700,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // 1. TextField cơ bản
//             CustomTextField(
//               hintText: 'Nhập họ tên',
//               controller: _nameController,
//               prefixIcon: Icon(Icons.person, color: Colors.grey.shade600),
//             ),
            
//             SizedBox(height: 16),
            
//             // 2. TextField cho email với validation
//             CustomTextField(
//               hintText: 'Email/Số Điện Thoại',
//               controller: _emailController,
//               keyboardType: TextInputType.emailAddress,
//               validator: _validateEmail,
//               prefixIcon: Icon(Icons.email, color: Colors.grey.shade600),
//               onChanged: (value) {
//                 print('Email changed: $value');
//               },
//             ),
            
//             SizedBox(height: 16),
            
//             // 3. TextField cho số điện thoại
//             CustomTextField(
//               hintText: 'Số điện thoại',
//               controller: _phoneController,
//               keyboardType: TextInputType.phone,
//               prefixIcon: Icon(Icons.phone, color: Colors.grey.shade600),
//               borderColor: Colors.blue.shade300,
//               focusedBorderColor: Colors.blue.shade700,
//             ),
            
//             SizedBox(height: 16),
            
//             // 4. TextField mật khẩu (tự động có icon ẩn/hiện)
//             CustomTextField(
//               hintText: 'Mật Khẩu',
//               controller: _passwordController,
//               isPassword: true,
//               validator: _validatePassword,
//               prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600),
//             ),
            
//             SizedBox(height: 16),
            
//             // 5. TextField tùy chỉnh màu sắc
//             CustomTextField(
//               hintText: 'Ghi chú (tùy chỉnh)',
//               maxLines: 3,
//               borderColor: Colors.green.shade300,
//               focusedBorderColor: Colors.green.shade700,
//               borderRadius: 12,
//               contentPadding: EdgeInsets.all(20),
//             ),
            
//             SizedBox(height: 20),
            
//             // Nút test
//             ElevatedButton(
//               onPressed: () {
//                 print('Name: ${_nameController.text}');
//                 print('Email: ${_emailController.text}');
//                 print('Phone: ${_phoneController.text}');
//                 print('Password: ${_passwordController.text}');
//               },
//               child: Text('Test Values'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red.shade700,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }