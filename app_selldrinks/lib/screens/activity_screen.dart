import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int totalOrders = 10;
  int confirmedOrders = 5;
  int canceledOrders = 2;

  String selectedFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Tìm kiếm đơn hàng'),
            content: TextField(
              decoration: InputDecoration(
                hintText: 'Nhập mã đơn hàng hoặc số điện thoại',
                hintStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Color(0xFF808080)),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Search logic
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF383838),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tìm kiếm'),
              ),
            ],
          ),
    );
  }

  void _showOrderDetailBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      height: 5,
                      width: 50,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFF808080),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    'Chi tiết đơn hàng',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF383838),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOrderDetailRow('Mã đơn hàng', '#123456'),
                  _buildOrderDetailRow('Khách hàng', 'Nguyễn Văn A'),
                  _buildOrderDetailRow('SĐT', '0909123456'),
                  _buildOrderDetailRow('Tổng tiền', '250.000đ'),
                  _buildOrderDetailRow('Trạng thái', 'Đã xác nhận'),
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
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Color(0xFF808080)),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
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
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF383838),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.coffee, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              '0',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white, size: 24),
            onPressed: _showSearchDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Color(0xFF383838),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Color(0xFF808080),
              labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent,
              tabs: [
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Wrap(spacing: 12, runSpacing: 8),
          const SizedBox(height: 16),

          const SizedBox(height: 16),
          Expanded(
            child:
                totalOrders == 0
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Color(0xFF808080),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Không Có Dữ Liệu.',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: Color(0xFF808080),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Bạn chưa có đơn hàng nào',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Color(0xFF808080)),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: totalOrders,
                      itemBuilder:
                          (context, index) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.receipt,
                                  color: Color(0xFF383838),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                'Đơn hàng #${index + 1}',
                                style: TextStyle(
                                  color: Color(0xFF383838),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Khách hàng: Nguyễn Văn A',
                                  style: TextStyle(
                                    color: Color(0xFF808080),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              trailing: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF808080),
                                  size: 20,
                                ),
                              ),
                              onTap: _showOrderDetailBottomSheet,
                            ),
                          ),
                    ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDripsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stars, size: 64, color: Color(0xFF808080)),
          SizedBox(height: 16),
          Text(
            'Điểm Drips',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Color(0xFF383838),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tính năng đang phát triển',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Color(0xFF808080)),
          ),
        ],
      ),
    );
  }
}
