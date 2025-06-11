import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_selldrinks/themes/highland_theme.dart'; // Đảm bảo import file theme

class ProductDetailScreen extends StatefulWidget {
  final String name;
  final String description;
  final String price;
  final String status;
  final String image;

  const ProductDetailScreen({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
    required this.image,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String _selectedSize = 'S';
  final Map<String, int> _sizePrices = {'S': 55000, 'M': 65000, 'L': 75000};

  @override
  Widget build(BuildContext context) {
    int basePrice =
        int.tryParse(widget.price.replaceAll(',', '').replaceAll(' đ', '')) ??
        0;
    int totalPrice = _quantity * _sizePrices[_selectedSize]!;

    return Scaffold(
      backgroundColor: highlandsTheme.appBarTheme.foregroundColor,
      body: Column(
        children: [
          // Padding và ảnh với bo góc
          Padding(
            padding: const EdgeInsets.only(
              top: 12.0, // Padding trên
              bottom: 16.0, // Padding dưới
              left: 24.0, // Padding trái
              right: 24.0, // Padding phải
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Stack(
                children: [
                  Image.asset(
                    widget.image,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey,
                          child: Center(child: Text('Image not found')),
                        ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color:
                            highlandsTheme
                                .bottomNavigationBarTheme
                                .unselectedItemColor,
                      ), // Màu xám
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tên và giá với bo góc
          Container(
            decoration: BoxDecoration(
              color: highlandsTheme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    style: highlandsTheme.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  NumberFormat('#,### đ').format(_sizePrices[_selectedSize]),
                  style: highlandsTheme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color:
                  highlandsTheme
                      .scaffoldBackgroundColor, // Nền xám nhạt từ theme
              // Hoặc dùng màu cụ thể nếu muốn: color: Color(0xFFF5F5F5),
              child: ListView(
                padding: EdgeInsets.only(top: 0, left: 16.0, right: 16.0),
                children: [
                  Text(
                    widget.description,
                    style: highlandsTheme.textTheme.bodyLarge,
                  ),
                  Text(
                    'Phần trang trí có thể bị ảnh hưởng khi vận chuyển.',
                    style: highlandsTheme.textTheme.bodyMedium,
                  ),
                  Text(
                    'Giá đã bao gồm 8% VAT.',
                    style: highlandsTheme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.grey, thickness: 1),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildSizeButton(context, 'S'),
                      _buildSizeButton(context, 'M'),
                      _buildSizeButton(context, 'L'),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.note, color: highlandsTheme.iconTheme.color),
                      SizedBox(width: 8),
                      Text(
                        'Ghi Chú',
                        style: highlandsTheme.textTheme.bodyMedium,
                      ),
                      Text(
                        ' (không bắt buộc)',
                        style: highlandsTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ghi Chú',
                      border: highlandsTheme.inputDecorationTheme.border,
                      focusedBorder:
                          highlandsTheme.inputDecorationTheme.focusedBorder,
                      fillColor: highlandsTheme.inputDecorationTheme.fillColor,
                      contentPadding: EdgeInsets.all(10),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.0),
        color: highlandsTheme.appBarTheme.foregroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  color: highlandsTheme.iconTheme.color,
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                ),
                Text('$_quantity', style: highlandsTheme.textTheme.titleLarge),
                IconButton(
                  icon: Icon(Icons.add),
                  color: highlandsTheme.iconTheme.color,
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
            ElevatedButton(
              style: highlandsTheme.elevatedButtonTheme.style,
              onPressed: () {},
              child: Text(
                'THÊM ${NumberFormat('#,### đ').format(totalPrice)}',
                style: highlandsTheme.textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeButton(BuildContext context, String size) {
    bool isSelected = _selectedSize == size;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? highlandsTheme.primaryColor : Colors.white,
          side: BorderSide(color: Colors.grey),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          setState(() {
            _selectedSize = size;
          });
        },
        child: Text(
          size,
          style: TextStyle(
            color:
                isSelected
                    ? highlandsTheme.textTheme.labelLarge?.color
                    : Colors.black,
          ),
        ),
      ),
    );
  }
}
