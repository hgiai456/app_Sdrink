import 'package:flutter/material.dart';
import 'package:app_selldrinks/adminArea/adminModels/order_admin.dart';
import 'package:app_selldrinks/adminArea/adminSevices/order_admin_service.dart';
import 'order_detail_admin_screen.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';
import 'package:intl/intl.dart';

class OrderAdminScreen extends StatefulWidget {
  final String token;
  const OrderAdminScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<OrderAdminScreen> createState() => _OrderAdminScreenState();
}

class _OrderAdminScreenState extends State<OrderAdminScreen> {
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  int totalPage = 1;
  List<OrderAdmin> orders = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchAllOrders(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMoreData) {
        loadMoreOrders();
      }
    }
  }

  Future<void> fetchAllOrders({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        orders.clear();
        hasMoreData = true;
      });
    }

    try {
      final result = await OrderAdminService.fetchOrders(
        widget.token,
        currentPage,
      );

      setState(() {
        if (refresh) {
          orders = result['orders'];
        } else {
          orders.addAll(result['orders']);
        }
        totalPage = result['totalPage'];
        hasMoreData = currentPage < totalPage;
        isLoading = false;
        isLoadingMore = false;
      });

      print('Số lượng đơn hàng: ${orders.length}');
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      print('Lỗi lấy đơn hàng: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
    }
  }

  Future<void> loadMoreOrders() async {
    if (currentPage >= totalPage) return;

    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    await fetchAllOrders();
  }

  Future<void> _refreshData() async {
    await fetchAllOrders(refresh: true);
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
        const SnackBar(
          content: Text('✅ Cập nhật trạng thái thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Cập nhật trạng thái thất bại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý đơn hàng', style: TextStyle(color: kDarkGray)),
        backgroundColor: kWhite,
        iconTheme: IconThemeData(color: kDarkGray),
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: kDarkGray),
            onPressed: _refreshData,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      backgroundColor: kLightGray,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: kDarkGray,
        child:
            isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: kDarkGray),
                      const SizedBox(height: 16),
                      Text(
                        'Đang tải dữ liệu...',
                        style: TextStyle(color: kMediumGray),
                      ),
                    ],
                  ),
                )
                : orders.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart, size: 64, color: kMediumGray),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có đơn hàng nào!',
                        style: TextStyle(
                          fontSize: 18,
                          color: kMediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Các đơn hàng sẽ hiển thị ở đây',
                        style: TextStyle(color: kMediumGray),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == orders.length) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(color: kDarkGray),
                      );
                    }

                    final order = orders[index];
                    return Card(
                      color: kWhite,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () async {
                          try {
                            final detail =
                                await OrderAdminService.fetchOrderDetail(
                                  widget.token,
                                  order.id,
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        OrderDetailAdminScreen(order: detail),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi tải chi tiết đơn hàng: $e'),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Đơn hàng #${order.id}',
                                    style: TextStyle(
                                      color: kDarkGray,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        order.status,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getStatusColor(order.status),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      _getStatusText(order.status),
                                      style: TextStyle(
                                        color: _getStatusColor(order.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Khách hàng: ${order.userName}',
                                style: TextStyle(
                                  color: kDarkGray,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (order.phone != null &&
                                  order.phone!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'SĐT: ${order.phone}',
                                  style: TextStyle(
                                    color: kMediumGray,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tổng tiền: ${NumberFormat('#,### đ').format(order.total)}',
                                    style: TextStyle(
                                      color: Colors.red[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy HH:mm',
                                    ).format(order.createdAt),
                                    style: TextStyle(
                                      color: kMediumGray,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        try {
                                          final detail =
                                              await OrderAdminService.fetchOrderDetail(
                                                widget.token,
                                                order.id,
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
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Lỗi tải chi tiết: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      icon: Icon(Icons.visibility, size: 16),
                                      label: const Text('Chi tiết'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: kDarkGray,
                                        side: BorderSide(color: kDarkGray),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<int>(
                                    onSelected:
                                        (value) => updateStatus(order, value),
                                    icon: Icon(Icons.edit, color: kDarkGray),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    itemBuilder:
                                        (context) => [
                                          for (int s = 1; s <= 7; s++)
                                            PopupMenuItem(
                                              value: s,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(s),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(_getStatusText(s)),
                                                ],
                                              ),
                                            ),
                                        ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  String _getStatusText(int status) {
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

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange[600]!;
      case 2:
        return Colors.blue[600]!;
      case 3:
        return Colors.purple[600]!;
      case 4:
        return Colors.green[600]!;
      case 5:
      case 7:
        return Colors.red[600]!;
      case 6:
        return Colors.grey[600]!;
      default:
        return kMediumGray;
    }
  }
}
