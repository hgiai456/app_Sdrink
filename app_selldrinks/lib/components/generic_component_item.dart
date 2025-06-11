import 'package:app_selldrinks/models/Order.dart';
import 'package:app_selldrinks/models/Product.dart';
import 'package:flutter/material.dart';

class GenericItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final String price;
  final Widget imageWidget;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const GenericItem({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    required this.price,
    required this.imageWidget,
    this.badge,
    this.badgeColor,
    this.onTap,
  });

  // Factory constructor cho Product
  factory GenericItem.fromProduct(Product product, {VoidCallback? onTap}) {
    return GenericItem(
      title: product.name,
      description: product.description,
      price:
          '${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
      imageWidget: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: AssetImage(product.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
      badge: product.badge,
      badgeColor: Colors.orange,
      onTap: onTap,
    );
  }

  factory GenericItem.fromOrder(Order order, {VoidCallback? onTap}) {
    return GenericItem(
      title: 'Đơn hàng #${order.id}',
      subtitle:
          'Địa chỉ: ${_truncateAddress(order.address)}', // Thay thế items.length
      description: _formatDate(order.createdAt),
      price:
          '${order.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
      imageWidget: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[100],
        ),
        child: Icon(Icons.receipt_long, size: 40, color: Colors.grey[600]),
      ),
      badge: order.badge ?? _getStatusText(order.status ?? 'unknown'),
      badgeColor: _getStatusColor(order.status ?? 'unknown'),
      onTap: onTap,
    );
  }

  // Helper method để cắt ngắn địa chỉ
  static String _truncateAddress(String address) {
    if (address.length > 30) {
      return '${address.substring(0, 30)}...';
    }
    return address;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                imageWidget,
                if (badge != null)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor ?? Colors.orange,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'delivered':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xử lý';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'preparing':
        return 'Đang pha chế';
      case 'ready':
        return 'Sẵn sàng';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}
