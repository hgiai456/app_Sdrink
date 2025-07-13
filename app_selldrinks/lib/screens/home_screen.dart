import 'package:app_selldrinks/screens/activity_screen.dart';
import 'package:app_selldrinks/screens/homepage.dart';
import 'package:app_selldrinks/screens/order_screen.dart';
import 'package:app_selldrinks/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_selldrinks/screens/store_screen.dart';
import 'package:app_selldrinks/screens/account_overview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _page;

  bool _isFirstBuild = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      _page = [
        HomePage(),
        OrderScreen(),
        ActivityScreen(),
        StoreScreen(),
        AccountOverviewScreen(),
      ];
      _isFirstBuild = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap:
            (index) => setState(() {
              _currentIndex = index;
            }),
        type: BottomNavigationBarType.fixed,
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_cafe),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Đặt hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Hoạt động',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Cửa hàng',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Khác'),
        ],
      ),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1; // Chuyển sang trang đặt hàng
                  });
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.shopping_bag, color: Colors.white),
              )
              : null,
    );
  }
}
