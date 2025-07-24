import 'package:app_selldrinks/screens/dieukhoandv_screen.dart';
import 'package:app_selldrinks/screens/faq_screen.dart';
import 'package:app_selldrinks/screens/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_selldrinks/screens/profile_screen.dart';
import 'package:app_selldrinks/screens/settings_screen.dart';
import 'package:app_selldrinks/screens/priacypolicy_screen.dart';
import 'package:app_selldrinks/screens/login_Screen.dart';
import 'package:app_selldrinks/services/cart_service.dart'; // Thêm import này

//Hồ sơ
class AccountOverviewScreen extends StatefulWidget {
  const AccountOverviewScreen({super.key});

  @override
  State<AccountOverviewScreen> createState() => _AccountOverviewScreenState();
}

class _AccountOverviewScreenState extends State<AccountOverviewScreen> {
  String firstName = '';
  String lastName = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('firstName') ?? '';
      lastName = prefs.getString('lastName') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF383838), // Header xám đậm
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Text(
                              'Tiếng Việt',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 36,
                              color: Color(0xFF383838),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (firstName.isNotEmpty || lastName.isNotEmpty)
                                      ? '$lastName $firstName | THÀNH VIÊN'
                                      : 'HI | THÀNH VIÊN',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: const [
                                    Text(
                                      'DRIPS: 0',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'Trả Trước: ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '0 đ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.verified,
                                      color: Colors.green,
                                      size: 13,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF383838),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                            child: const Text(
                              'NẠP TIỀN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hồ sơ & Cài đặt
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Color(0xFF383838),
                      ),
                      title: const Text(
                        'Hồ Sơ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF383838),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF808080),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                        _loadName(); // Reload tên khi quay lại
                      },
                    ),
                    Divider(height: 1, color: Color(0xFFF5F5F5)),
                    ListTile(
                      leading: const Icon(
                        Icons.settings,
                        color: Color(0xFF383838),
                      ),
                      title: const Text(
                        'Cài Đặt',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF383838),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF808080),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Thông tin chung
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: const Text(
                  'Thông Tin Chung',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF383838),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.description,
                        color: Color(0xFF383838),
                      ),
                      title: const Text(
                        'Điều khoản dịch vụ',
                        style: TextStyle(color: Color(0xFF383838)),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF808080),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsOfServiceScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: Color(0xFFF5F5F5)),
                    ListTile(
                      leading: const Icon(
                        Icons.privacy_tip,
                        color: Color(0xFF383838),
                      ),
                      title: const Text(
                        'Chính sách bảo mật',
                        style: TextStyle(color: Color(0xFF383838)),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF808080),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: Color(0xFFF5F5F5)),
                    ListTile(
                      leading: const Icon(Icons.info, color: Color(0xFF383838)),
                      title: const Text(
                        'Giới Thiệu Về Phiên Bản Ứng Dụng',
                        style: TextStyle(color: Color(0xFF383838)),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF808080),
                      ),
                      onTap: null,
                    ),
                  ],
                ),
              ),
              // Trung tâm trợ giúp
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: const Text(
                  'Trung Tâm Trợ Giúp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF383838),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.live_help,
                        color: Color(0xFF383838),
                      ),
                      title: const Text(
                        'Câu Hỏi Thường Gặp',
                        style: TextStyle(color: Color(0xFF383838)),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF808080),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FAQScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: Color(0xFFF5F5F5)),
                    ListTile(
                      leading: const Icon(
                        Icons.feedback,
                        color: Color(0xFF383838),
                      ),
                      title: const Text(
                        'Phản Hồi & Hỗ Trợ',
                        style: TextStyle(color: Color(0xFF383838)),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF808080),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FeedbackScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Nút đăng xuất
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showLogoutDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF383838),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                    child: const Text(
                      'ĐĂNG XUẤT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng Xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Đăng Xuất'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();

                // Lấy user ID trước khi xóa để xóa session
                final userId = prefs.getInt('userId');

                // Xóa session cho user hiện tại
                if (userId != null) {
                  await CartService().clearSessionForUser(
                    specificUserId: userId,
                  );
                } else {
                  await CartService().clearSession();
                }

                // Xóa tất cả thông tin user
                await prefs.remove('token');
                await prefs.remove('userId');
                await prefs.remove('userName');
                await prefs.remove('userEmail');
                await prefs.remove('userPhone');
                await prefs.remove('userAddress');
                await prefs.remove('userRole');
                await prefs.remove('firstName');
                await prefs.remove('lastName');
                await prefs.remove('email');
                await prefs.remove('phone');
                await prefs.remove('address');
                await prefs.remove('dob');
                await prefs.remove('gender');
                await prefs.remove('isVerified');
                await prefs.remove('createdAt');
                await prefs.remove('updatedAt');

                print('Logout - All user data and session cleared');

                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
