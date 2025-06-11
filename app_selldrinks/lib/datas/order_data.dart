import 'package:app_selldrinks/models/Order.dart';

class OrderSampleData {
  static List<Order> getSampleOrders() {
    return [
      Order(
        id: 1001,
        price: 35000,
        address: '123 Nguyễn Văn Linh, Quận 7, TP.HCM',
        note: 'Ít đường, nhiều đá',
        imageUrl: 'assets/images/logo.png',
        phone: '0901234567',
        totalAmount: 35000,
        createdAt: DateTime.now().subtract(Duration(minutes: 30)),
        userId: 1,
        status: 'pending',
        badge: 'Mới',
      ),

      Order(
        id: 1002,
        price: 45000,
        address: '456 Lê Văn Việt, Quận 9, TP.HCM',
        note: 'Giao tận tay, không gọi điện',
        imageUrl: 'assets/images/logo.png',
        phone: '0912345678',
        totalAmount: 90000,
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
        userId: 2,
        status: 'confirmed',
        badge: 'Hot',
      ),

      Order(
        id: 1003,
        price: 28000,
        address: '789 Hoàng Văn Thụ, Quận Tân Bình, TP.HCM',
        note: 'Giao trước 3h chiều',
        imageUrl: 'assets/images/logo.png',
        phone: '0923456789',
        totalAmount: 56000,
        createdAt: DateTime.now().subtract(Duration(hours: 2, minutes: 15)),
        userId: 3,
        status: 'preparing',
        badge: null,
      ),

      Order(
        id: 1004,
        price: 52000,
        address: '321 Cách Mạng Tháng 8, Quận 3, TP.HCM',
        note: 'Thanh toán tiền mặt',
        imageUrl: 'assets/images/logo.png',
        phone: '0934567890',
        totalAmount: 104000,
        createdAt: DateTime.now().subtract(Duration(hours: 3)),
        userId: 4,
        status: 'ready',
        badge: 'VIP',
      ),

      Order(
        id: 1005,
        price: 38000,
        address: '654 Võ Văn Tần, Quận 1, TP.HCM',
        note: 'Để ở bàn bảo vệ',
        imageUrl: 'assets/images/logo.png',
        phone: '0945678901',
        totalAmount: 76000,
        createdAt: DateTime.now().subtract(Duration(hours: 4, minutes: 30)),
        userId: 5,
        status: 'delivered',
        badge: null,
      ),

      Order(
        id: 1006,
        price: 42000,
        address: '987 Nguyễn Thị Minh Khai, Quận 1, TP.HCM',
        note: 'Khách hàng hủy đơn',
        imageUrl: 'assets/images/logo.png',
        phone: '0956789012',
        totalAmount: 42000,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        userId: 6,
        status: 'cancelled',
        badge: 'Hủy',
      ),

      Order(
        id: 1007,
        price: 33000,
        address: '147 Pasteur, Quận 1, TP.HCM',
        note: 'Giao lần 2 do khách vắng nhà',
        imageUrl: 'assets/images/logo.png',
        phone: '0967890123',
        totalAmount: 99000,
        createdAt: DateTime.now().subtract(Duration(days: 1, hours: 2)),
        userId: 2,
        status: 'pending',
        badge: 'Giao lại',
      ),

      Order(
        id: 1008,
        price: 48000,
        address: '258 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM',
        note: 'Khách VIP, ưu tiên giao nhanh',
        imageUrl: 'assets/images/logo.png',
        phone: '0978901234',
        totalAmount: 144000,
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        userId: 2,
        status: 'delivered',
        badge: 'VIP',
      ),

      Order(
        id: 1009,
        price: 36000,
        address: '369 Nguyễn Đình Chiểu, Quận 3, TP.HCM',
        note: 'Không cần túi nilon',
        imageUrl: 'assets/images/logo.png',
        phone: '0989012345',
        totalAmount: 72000,
        createdAt: DateTime.now().subtract(Duration(days: 2, hours: 5)),
        userId: 1,
        status: 'confirmed',
        badge: 'Eco',
      ),

      Order(
        id: 1010,
        price: 55000,
        address: '741 Lê Hồng Phong, Quận 5, TP.HCM',
        note: 'Đơn hàng khuyến mãi 50%',
        imageUrl: 'assets/images/logo.png',
        phone: '0990123456',
        totalAmount: 110000,
        createdAt: DateTime.now().subtract(Duration(days: 3)),
        userId: 3,
        status: 'preparing',
        badge: 'Khuyến mãi',
      ),

      Order(
        id: 1011,
        price: 29000,
        address: '852 Tôn Đức Thắng, Quận 1, TP.HCM',
        note: 'Giao trong giờ hành chính',
        imageUrl: 'assets/images/logo.png',
        phone: '0901234561',
        totalAmount: 58000,
        createdAt: DateTime.now().subtract(Duration(days: 3, hours: 8)),
        userId: 1,
        status: 'ready',
        badge: null,
      ),

      Order(
        id: 1012,
        price: 44000,
        address: '963 Hai Bà Trưng, Quận 1, TP.HCM',
        note: 'Sinh viên, giảm giá 10%',
        imageUrl: 'assets/images/logo.png',
        phone: '0912345672',
        totalAmount: 88000,
        createdAt: DateTime.now().subtract(Duration(days: 4)),
        userId: 2,
        status: 'delivered',
        badge: 'Sinh viên',
      ),
    ];
  }

  // Lấy đơn hàng theo trạng thái
  static List<Order> getOrdersByStatus(String status) {
    return getSampleOrders().where((order) => order.status == status).toList();
  }

  // Lấy đơn hàng theo user
  static List<Order> getOrdersByUser(String userId) {
    return getSampleOrders().where((order) => order.userId == userId).toList();
  }

  // Lấy đơn hàng trong khoảng thời gian
  static List<Order> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return getSampleOrders()
        .where(
          (order) =>
              order.createdAt.isAfter(startDate) &&
              order.createdAt.isBefore(endDate),
        )
        .toList();
  }

  // Lấy đơn hàng hôm nay
  static List<Order> getTodayOrders() {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    return getOrdersByDateRange(startOfDay, endOfDay);
  }

  // Thống kê tổng doanh thu
  static double getTotalRevenue() {
    return getSampleOrders()
        .where((order) => order.status == 'delivered')
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  // Đếm đơn hàng theo trạng thái
  static Map<String, int> getOrderCountByStatus() {
    Map<String, int> statusCount = {};

    for (Order order in getSampleOrders()) {
      String status = order.status ?? 'unknown';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }

    return statusCount;
  }
}

// Cách sử dụng:
// List<Order> allOrders = OrderSampleData.getSampleOrders();
// List<Order> pendingOrders = OrderSampleData.getOrdersByStatus('pending');
// List<Order> userOrders = OrderSampleData.getOrdersByUser('user001');
// List<Order> todayOrders = OrderSampleData.getTodayOrders();
// double totalRevenue = OrderSampleData.getTotalRevenue();
// Map<String, int> statusCount = OrderSampleData.getOrderCountByStatus();
