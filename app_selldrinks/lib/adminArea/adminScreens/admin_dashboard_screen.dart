import 'package:flutter/material.dart';
import 'package:app_selldrinks/adminArea/adminScreens/product_admin_screen.dart';
import 'package:app_selldrinks/adminArea/adminScreens/category_admin_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String token;
  const AdminDashboardScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.shopping_bag),
              label: Text('Quản lý sản phẩm'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                textStyle: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductAdminScreen(token: token),
                  ),
                );
              },
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              icon: Icon(Icons.category),
              label: Text('Quản lý danh mục'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50),
                textStyle: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryAdminScreen(token: token),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
