import 'package:flutter/material.dart';
import 'package:app_selldrinks/models/order_user_model.dart';
import 'package:app_selldrinks/services/order_user_service.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Order data
  List<OrderUserModel> orders = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  int totalPage = 1;
  int totalOrders = 0;
  String? errorMessage;

  // Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  String selectedFilter = 'Tất cả';
  final List<String> filterOptions = [
    'Tất cả',
    'Đang chờ xử lý',
    'Đang chuẩn bị',
    'Đang giao',
    'Đã giao',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreOrders();
      }
    });
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        orders.clear();
        errorMessage = null;
      });
    }

    try {
      final result = await OrderUserService.fetchUserOrders(
        page: currentPage,
        limit: 10,
      );

      if (result['success'] == true) {
        setState(() {
          if (refresh || currentPage == 1) {
            orders = result['orders'];
          } else {
            orders.addAll(result['orders']);
          }
          totalOrders = result['totalOrders'];
          totalPage = result['totalPage'];
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          errorMessage = result['error'] ?? 'Lỗi không xác định';
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreOrders() async {
    if (isLoadingMore || currentPage >= totalPage) return;

    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    await _loadOrders();
  }

  Future<void> _refreshOrders() async {
    await _loadOrders(refresh: true);
  }

  void _showSearchDialog() {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tìm kiếm đơn hàng'),
            content: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Nhập mã đơn hàng hoặc số điện thoại',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final query = searchController.text.trim();
                  if (query.isNotEmpty) {
                    Navigator.of(context).pop();
                    await _searchOrders(query);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF383838),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tìm kiếm'),
              ),
            ],
          ),
    );
  }

  Future<void> _searchOrders(String query) async {
    setState(() {
      isLoading = true;
    });

    try {
      final searchResults = await OrderUserService.searchOrders(query);
      setState(() {
        orders = searchResults;
        totalOrders = searchResults.length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _showOrderDetailBottomSheet(OrderUserModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      height: 5,
                      width: 50,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF808080),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đơn hàng #${order.id}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF383838),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: order.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: order.statusColor),
                        ),
                        child: Text(
                          order.statusText,
                          style: TextStyle(
                            color: order.statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Order info
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildOrderDetailRow(
                          'Ngày đặt',
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(order.createdAt),
                        ),
                        _buildOrderDetailRow('Khách hàng', order.phone),
                        _buildOrderDetailRow('Địa chỉ', order.address),
                        _buildOrderDetailRow('Ghi chú', order.note),
                        _buildOrderDetailRow(
                          'Tổng tiền',
                          NumberFormat('#,### đ').format(order.total),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Sản phẩm đã đặt:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF383838),
                          ),
                        ),

                        const SizedBox(height: 12),

                        ...order.orderDetails
                            .map((detail) => _buildProductDetailItem(detail))
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF808080),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF383838),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailItem(OrderDetailUser detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                detail.productImage.isNotEmpty
                    ? Image.network(
                      detail.productImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                    )
                    : Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
          ),

          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF383838),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SL: ${detail.quantity} x ${NumberFormat('#,### đ').format(detail.price)}',
                  style: const TextStyle(
                    color: Color(0xFF808080),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Total price
          Text(
            NumberFormat('#,### đ').format(detail.totalPrice),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF383838),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF383838),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.coffee, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              totalOrders.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 24),
            onPressed: _showSearchDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF383838),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF808080),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt, size: 18),
                      SizedBox(width: 6),
                      Text('Đơn Đặt Hàng'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars, size: 18),
                      SizedBox(width: 6),
                      Text('Điểm Drips'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOrdersTab(), _buildDripsTab()],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = filterOptions[index];
                  final isSelected = selectedFilter == filter;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedFilter = filter;
                        });
                        // TODO: Implement filter logic
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFF383838),
                      labelStyle: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF383838),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Orders list
            Expanded(child: _buildOrdersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    if (isLoading && orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadOrders(refresh: true),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Color(0xFF808080)),
            const SizedBox(height: 16),
            const Text(
              'Không Có Đơn Hàng.',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF808080),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn chưa có đơn hàng nào',
              style: TextStyle(color: Color(0xFF808080)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: orders.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= orders.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final order = orders[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  order.firstProductImage.isNotEmpty
                      ? Image.network(
                        order.firstProductImage,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 50,
                              height: 50,
                              color: const Color(0xFFF5F5F5),
                              child: const Icon(
                                Icons.receipt,
                                color: Color(0xFF383838),
                              ),
                            ),
                      )
                      : Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt,
                          color: Color(0xFF383838),
                        ),
                      ),
            ),
            title: Text(
              'Đơn hàng #${order.id}',
              style: const TextStyle(
                color: Color(0xFF383838),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${order.totalQuantity} sản phẩm • ${NumberFormat('#,### đ').format(order.total)}',
                  style: const TextStyle(
                    color: Color(0xFF808080),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF808080),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: order.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.statusText,
                    style: TextStyle(
                      color: order.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Color(0xFF808080),
                size: 20,
              ),
            ),
            onTap: () => _showOrderDetailBottomSheet(order),
          ),
        );
      },
    );
  }

  Widget _buildDripsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stars, size: 64, color: Color(0xFF808080)),
          SizedBox(height: 16),
          Text(
            'Điểm Drips',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF383838),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tính năng đang phát triển',
            style: TextStyle(color: Color(0xFF808080)),
          ),
        ],
      ),
    );
  }
}
