import 'package:flutter/material.dart';
import 'package:app_selldrinks/adminArea/adminModels/order_admin.dart';
import 'package:app_selldrinks/adminArea/adminSevices/order_admin_service.dart';
import 'order_detail_admin_screen.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';

class OrderAdminScreen extends StatefulWidget {
  final String token;
  const OrderAdminScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<OrderAdminScreen> createState() => _OrderAdminScreenState();
}

class _OrderAdminScreenState extends State<OrderAdminScreen> {
  int currentPage = 1;
  int totalPage = 1;
  List<OrderAdmin> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders({int page = 1}) async {
    setState(() => isLoading = true);
    try {
      final result = await OrderAdminService.fetchOrders(widget.token, page);
      orders = result['orders'];
      currentPage = result['currentPage'];
      totalPage = result['totalPage'];
      print('Số lượng đơn hàng: ${orders.length}');
    } catch (e) {
      print('Lỗi lấy đơn hàng: $e');
    }
    setState(() => isLoading = false);
  }

  void updateStatus(OrderAdmin order, int newStatus) async {
    bool success = await OrderAdminService.updateOrderStatus(
      widget.token,
      order.id,
      newStatus,
    );
    if (success) {
      setState(() {
        order.status = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái thành công!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cập nhật trạng thái thất bại!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý đơn hàng', style: TextStyle(color: kDarkGray)),
        backgroundColor: kWhite,
        iconTheme: IconThemeData(color: kDarkGray),
      ),
      backgroundColor: kLightGray,
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: kDarkGray))
              : Column(
                children: [
                  Expanded(
                    child:
                        orders.isEmpty
                            ? Center(
                              child: Text(
                                'Không có đơn hàng nào!',
                                style: TextStyle(color: kMediumGray),
                              ),
                            )
                            : ListView.builder(
                              itemCount: orders.length,
                              itemBuilder: (_, i) {
                                final o = orders[i];
                                return Card(
                                  color: kWhite,
                                  child: ListTile(
                                    title: Text(
                                      'Đơn #${o.id} - Tổng: ${o.total}đ',
                                      style: TextStyle(color: kDarkGray),
                                    ),
                                    subtitle: Text(
                                      'Trạng thái: ${statusText(o.status)}',
                                      style: TextStyle(color: kMediumGray),
                                    ),
                                    trailing: PopupMenuButton<int>(
                                      onSelected:
                                          (value) => updateStatus(o, value),
                                      itemBuilder:
                                          (context) => [
                                            for (int s = 1; s <= 7; s++)
                                              PopupMenuItem(
                                                value: s,
                                                child: Text(statusText(s)),
                                              ),
                                          ],
                                      child: Icon(Icons.edit, color: kDarkGray),
                                    ),
                                    onTap: () async {
                                      final detail =
                                          await OrderAdminService.fetchOrderDetail(
                                            widget.token,
                                            o.id,
                                          );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => OrderDetailAdminScreen(
                                                order: detail,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                  buildPagination(),
                ],
              ),
    );
  }

  Widget buildPagination() {
    List<Widget> pages = [];
    int start = (currentPage - 2 > 0) ? currentPage - 2 : 1;
    int end = (currentPage + 2 < totalPage) ? currentPage + 2 : totalPage;

    if (start > 1) {
      pages.add(pageButton(1));
      if (start > 2) pages.add(Text('...'));
    }
    for (int i = start; i <= end; i++) {
      pages.add(pageButton(i));
    }
    if (end < totalPage) {
      if (end < totalPage - 1) pages.add(Text('...'));
      pages.add(pageButton(totalPage));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed:
              currentPage > 1 ? () => fetchOrders(page: currentPage - 1) : null,
        ),
        ...pages,
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed:
              currentPage < totalPage
                  ? () => fetchOrders(page: currentPage + 1)
                  : null,
        ),
      ],
    );
  }

  Widget pageButton(int page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: page == currentPage ? kDarkGray : kWhite,
          foregroundColor: page == currentPage ? kWhite : kDarkGray,
          minimumSize: Size(36, 36),
          padding: EdgeInsets.zero,
        ),
        onPressed: page == currentPage ? null : () => fetchOrders(page: page),
        child: Text('$page'),
      ),
    );
  }

  String statusText(int status) {
    switch (status) {
      case 1:
        return 'Đang chờ xử lý';
      case 2:
        return 'Đang chuẩn bị';
      case 3:
        return 'Đang giao';
      case 4:
        return 'Đã giao';
      case 5:
        return 'Đã hủy';
      case 6:
        return 'Đã hoàn tiền';
      case 7:
        return 'Không thành công';
      default:
        return 'Không xác định';
    }
  }
}
