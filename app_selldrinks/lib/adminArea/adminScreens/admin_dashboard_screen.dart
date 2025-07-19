import 'package:flutter/material.dart';
import 'package:app_selldrinks/adminArea/adminScreens/product_admin_screen.dart';
import 'package:app_selldrinks/adminArea/adminScreens/category_admin_screen.dart';
import 'package:app_selldrinks/adminArea/adminScreens/size_admin_screen.dart';
import 'package:app_selldrinks/adminArea/adminScreens/order_admin_screen.dart';
import 'package:app_selldrinks/adminArea/adminScreens/prodetail_admin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_selldrinks/screens/login_Screen.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String token;
  const AdminDashboardScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      OrderAdminScreen(token: widget.token),
      ProductAdminScreen(token: widget.token),
      CategoryAdminScreen(token: widget.token),
      SizeAdminScreen(token: widget.token),
      ProdetailAdminScreen(token: widget.token),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(color: kDarkGray)),
        backgroundColor: kWhite,
        iconTheme: IconThemeData(color: kDarkGray),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: kDarkGray),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      backgroundColor: kLightGray,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: kWhite,
        selectedItemColor: kDarkGray,
        unselectedItemColor: kMediumGray,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Đơn Hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Sản Phẩm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Danh mục',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.straighten), label: 'Size'),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Chi tiết SP',
          ),
        ],
      ),
    );
  }
}
