import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF4A2B1D), // Màu nâu của Highland
            size: 20, // Kích thước phù hợp
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cài Đặt',
          style: TextStyle(
            color: Color(0xFF4A2B1D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cài Đặt Tài Khoản Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                'Cài Đặt Tài Khoản',
                style: TextStyle(
                  color: Color(0xFF4A2B1D),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(
                  Icons.person_off_outlined,
                  color: Colors.red,
                  size: 24,
                ),
                title: Text(
                  'Xóa Tài Khoản',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  // Xử lý khi nhấn xóa tài khoản
                },
              ),
            ),

            // Bảo Mật Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 10),
              child: Text(
                'Bảo Mật',
                style: TextStyle(
                  color: Color(0xFF4A2B1D),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(
                  Icons.lock_outline,
                  color: Color(0xFF4A2B1D),
                  size: 24,
                ),
                title: Text(
                  'Thay Đổi Mật Khẩu',
                  style: TextStyle(color: Color(0xFF4A2B1D), fontSize: 16),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 20,
                ),
                onTap: () {
                  // Xử lý khi nhấn thay đổi mật khẩu
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
