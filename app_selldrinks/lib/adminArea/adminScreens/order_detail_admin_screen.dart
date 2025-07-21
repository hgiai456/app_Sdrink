import 'package:flutter/material.dart';
import 'package:app_selldrinks/adminArea/adminModels/order_admin.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';

class OrderDetailAdminScreen extends StatelessWidget {
  final OrderAdmin order;
  const OrderDetailAdminScreen({Key? key, required this.order})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết đơn #${order.id}',
          style: TextStyle(color: kDarkGray),
        ),
        backgroundColor: kWhite,
        iconTheme: IconThemeData(color: kDarkGray),
      ),
      backgroundColor: kLightGray,
      body: ListView(
        children: [
          Card(
            color: kWhite,
            child: ListTile(
              title: Text(
                'Tổng tiền: ${order.total}đ',
                style: TextStyle(color: kDarkGray),
              ),
              subtitle: Text(
                'Ghi chú: ${order.note ?? ''}',
                style: TextStyle(color: kMediumGray),
              ),
            ),
          ),
          Divider(color: kMediumGray),
          ...order.orderDetails.map(
            (d) => Card(
              color: kWhite,
              child: ListTile(
                title: Text(
                  '${d.productDetail?['name'] ?? 'Sản phẩm'}',
                  style: TextStyle(color: kDarkGray),
                ),
                subtitle: Text(
                  'SL: ${d.quantity} - Giá: ${d.price}đ',
                  style: TextStyle(color: kMediumGray),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
