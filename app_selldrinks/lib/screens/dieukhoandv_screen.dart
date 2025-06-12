import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF4B2B1B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Điều Khoản Dịch Vụ',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: Color(0xFF4B2B1B),
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
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ĐIỀU KHOẢN VÀ ĐIỀU KIỆN ÁP DỤNG CỦA ỨNG DỤNG HIGHLANDS COFFEE',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cập nhật lần cuối vào ngày 13/06/2023',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'VUI LÒNG ĐỌC NHỮNG ĐIỀU KHOẢN SỬ DỤNG NÀY CẨN THẬN.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'VIỆC TẢI XUỐNG, CÀI ĐẶT, TRUY CẬP HOẶC SỬ DỤNG ỨNG DỤNG DI ĐỘNG HIGHLANDS COFFEE ("ỨNG DỤNG") CÓ NGHĨA LÀ BẠN ĐÃ ĐỒNG Ý VỚI CÁC ĐIỀU KHOẢN SỬ DỤNG ("ĐIỀU KHOẢN") MÀ CÔNG TY CỔ PHẦN DỊCH VỤ & CÀ PHÊ CAO NGUYÊN ("HIGHLANDS COFFEE", "chúng tôi", hoặc "của chúng tôi") CÓ THỂ SỬA ĐỔI THEO TỪNG THỜI ĐIỂM, VÀ TRỞ THÀNH THỎA THUẬN RÀNG BUỘC GIỮA BẠN ("NGƯỜI DÙNG" HOẶC "BẠN") VÀ HIGHLANDS COFFEE ĐIỀU CHỈNH VIỆC TRUY CẬP VÀO VÀ SỬ DỤNG ỨNG DỤNG. NẾU NGƯỜI DÙNG KHÔNG ĐỒNG Ý VỚI TẤT CẢ CÁC ĐIỀU KHOẢN NÀY, THÌ NGƯỜI DÙNG KHÔNG ĐƯỢC SỬ DỤNG ỨNG DỤNG VÀ PHẢI NGƯNG SỬ DỤNG NGAY LẬP TỨC.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Đăng ký',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Để sử dụng các chức năng nhất định của Ứng dụng của chúng tôi, bạn sẽ cần phải đăng ký tài khoản và mật khẩu của bạn. Chúng tôi có quyền xóa, lấy lại, từ chối hoặc yêu cầu thay đổi tên người dùng mà bạn chọn nếu chúng tôi xác định, theo quyết định riêng của chúng tôi, tên người dùng đó không phù hợp hoặc bị phản đối.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  // Thêm các phần nội dung khác tương tự
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
