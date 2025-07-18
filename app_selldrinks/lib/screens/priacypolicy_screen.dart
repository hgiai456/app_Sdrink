import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF383838),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chính Sách Bảo Mật',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: Color(0xFF383838),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHÍNH SÁCH CHƯƠNG TRÌNH THÀNH VIÊN HIGHLANDS COFFEE 2023',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),

              _buildSection('1. ĐIỀU KIỆN THAM GIA', [
                'Để tham gia chương trình thành viên Highlands Coffee, khách hàng cần tải ứng dụng Highlands Coffee trên App Store (iOS) hoặc Google Play (Android) và đăng ký tài khoản thành viên bằng cách cung cấp số điện thoại và (không bắt buộc): họ tên, thư điện tử, giới tính và ngày tháng năm sinh.',
                'Chương trình chỉ áp dụng cho khách hàng cá nhân, không áp dụng cho nhóm, công ty, tập thể với mục đích thương mại dưới mọi hình thức.',
                'Mỗi khách hàng chỉ được sở hữu (01) tài khoản thành viên Highlands Coffee.',
              ], theme),

              _buildSection('2. ĐĂNG KÝ TÀI KHOẢN', [
                'Bạn tham gia vào chương trình thành viên Highlands Coffee theo các bước sau:',
                '• Bước 1: Tải ứng dụng Highlands Coffee trên App Store (iOS) hoặc Google Play (Android)',
                '• Bước 2: Cung cấp số điện thoại và nhập mã OTP để hoàn tất đăng ký tài khoản',
              ], theme),

              _buildSection('3. QUY ĐỊNH VỀ TÍCH LŨY DRIP', [
                'Trên ứng dụng Highlands Coffee, điểm thưởng được gọi là "DRIP"',
                'Với mỗi 10.000 VND chi tiêu thông qua ứng dụng Highlands Coffee, khách hàng sẽ tích được 01 DRIP. Mọi khoản chi tiêu lẻ trên 10.000 VND sẽ được làm tròn xuống phần 10.000 VND gần nhất.',
                '(Ví dụ: khách hàng chi tiêu 29.000 VND thông qua ứng dụng Highlands Coffee, khách hàng sẽ tích được 2 DRIPS vào tài khoản thành viên)',
              ], theme),

              _buildSection('4. QUY ĐỊNH VỀ ĐỔI DRIP', [
                'Hiện tại chương trình đổi Drips nhận ưu đãi đang tạm ngưng, chúng tôi sẽ sớm cập nhật đến quý khách.',
              ], theme),

              _buildSection(
                '5. QUY ĐỊNH VỀ HẠNG THÀNH VIÊN & ƯU ĐÃI CHO HẠNG THÀNH VIÊN',
                [
                  'Hiện tại, Highlands Coffee áp dụng 02 hạng thành viên',
                  '• Thành viên thường',
                  '• Thành viên Phin Bạc',
                ],
                theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> contents, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...contents.map(
          (content) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
