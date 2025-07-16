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
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
                  backgroundColor: Theme.of(context).primaryColor,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
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
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    'Chi tiết đơn hàng',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.coffee, color: Theme.of(context).iconTheme.color),
            const SizedBox(width: 4),
            Text(
              '0',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
            onPressed: _showSearchDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).scaffoldBackgroundColor,
          labelColor: Theme.of(context).scaffoldBackgroundColor,
          unselectedLabelColor: Theme.of(context).scaffoldBackgroundColor,
          tabs: const [Tab(text: 'Đơn Đặt Hàng'), Tab(text: 'Điểm Drips')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersTab(),
          const Center(child: Text('Tab điểm Drips')),
        ],
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
                      child: Text(
                        'Không Có Dữ Liệu.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: totalOrders,
                      itemBuilder:
                          (context, index) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: Icon(
                                Icons.receipt,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text('Đơn hàng #${index + 1}'),
                              subtitle: Text('Khách hàng: Nguyễn Văn A'),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).iconTheme.color,
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
}
