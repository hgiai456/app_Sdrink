import 'package:app_selldrinks/adminArea/adminModels/order_detail_admin.dart';
import 'package:flutter/material.dart';
import 'package:app_selldrinks/adminArea/adminModels/order_admin.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';
import 'package:intl/intl.dart';

class OrderDetailAdminScreen extends StatelessWidget {
  final OrderAdmin order;
  const OrderDetailAdminScreen({Key? key, required this.order})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết đơn hàng #${order.id}',
          style: TextStyle(
            color: kDarkGray,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kWhite,
        iconTheme: IconThemeData(color: kDarkGray),
        elevation: 1,
      ),
      backgroundColor: kLightGray,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin đơn hàng
            _buildOrderInfoCard(),
            const SizedBox(height: 16),

            // Thông tin khách hàng
            _buildCustomerInfoCard(),
            const SizedBox(height: 16),

            // Danh sách sản phẩm
            _buildProductListCard(),
            const SizedBox(height: 16),

            // Tổng kết đơn hàng
            _buildOrderSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      color: kWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: kDarkGray, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Thông tin đơn hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kDarkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildInfoRow('Mã đơn hàng:', '#${order.id}'),
            _buildInfoRow(
              'Trạng thái:',
              _getStatusText(order.status),
              statusColor: _getStatusColor(order.status),
            ),
            _buildInfoRow(
              'Ngày đặt:',
              DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
            ),
            _buildInfoRow(
              'Cập nhật:',
              DateFormat('dd/MM/yyyy HH:mm').format(order.updatedAt),
            ),

            if (order.note != null && order.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Ghi chú:', order.note!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      color: kWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: kDarkGray, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Thông tin khách hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kDarkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildInfoRow('Tên khách hàng:', order.userName),

            if (order.phone != null && order.phone!.isNotEmpty)
              _buildInfoRow('Số điện thoại:', order.phone!),

            if (order.address != null && order.address!.isNotEmpty)
              _buildInfoRow('Địa chỉ:', order.address!),

            if (order.userId != null)
              _buildInfoRow('Mã khách hàng:', '#${order.userId}'),

            if (order.sessionId != null)
              _buildInfoRow('Session ID:', order.sessionId!),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListCard() {
    return Card(
      color: kWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: kDarkGray, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Danh sách sản phẩm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kDarkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ...order.orderDetails.asMap().entries.map((entry) {
              final index = entry.key;
              final detail = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(height: 24),
                  _buildProductItem(detail),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(OrderDetailAdmin detail) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kLightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kDarkGray,
                      ),
                    ),
                    if (detail.specification.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        detail.specification,
                        style: TextStyle(fontSize: 14, color: kMediumGray),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'x${detail.quantity}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kDarkGray,
                    ),
                  ),
                  Text(
                    NumberFormat('#,### đ').format(detail.price),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                  ),
                  if (detail.oldPrice != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      NumberFormat('#,### đ').format(detail.oldPrice!),
                      style: TextStyle(
                        fontSize: 12,
                        color: kMediumGray,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thành tiền:',
                style: TextStyle(fontSize: 14, color: kMediumGray),
              ),
              Text(
                NumberFormat('#,### đ').format(detail.price * detail.quantity),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kDarkGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final totalItems = order.orderDetails.fold<int>(
      0,
      (sum, detail) => sum + detail.quantity,
    );

    return Card(
      color: kWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: kDarkGray, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Tổng kết đơn hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kDarkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSummaryRow('Số lượng sản phẩm:', '$totalItems món'),
            _buildSummaryRow(
              'Tạm tính:',
              NumberFormat('#,### đ').format(order.total),
            ),
            _buildSummaryRow(
              'Phí giao hàng:',
              'Miễn phí',
              valueColor: Colors.green[600],
            ),

            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TỔNG CỘNG:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kDarkGray,
                  ),
                ),
                Text(
                  NumberFormat('#,### đ').format(order.total),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: kMediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: statusColor ?? kDarkGray,
                fontWeight:
                    statusColor != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: kMediumGray)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor ?? kDarkGray,
            ),
          ),
        ],
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
