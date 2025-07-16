import 'package:app_selldrinks/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_selldrinks/models/store.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Store? selectedStore;
  bool isDelivery = true;
  int freezeQuantity = 1;
  int cheeseQuantity = 1;

  final List<Store> stores = [
    Store(
      id: '1',
      name: '35 Thang Long Tan Binh HCMC',
      address: '35 Thăng Long',
      district: 'P. 4, Q. Tân Bình',
      phone: '(028) 7100 0035',
      image: '',
    ),
    Store(
      id: '2',
      name: 'Store 2',
      address: '123 Nguyen Van Cu',
      district: 'P. 1, Q. 1',
      phone: '(028) 1234 5678',
      image: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedStore = stores.first;
  }

  int get totalAmount => (freezeQuantity * 55000) + (cheeseQuantity * 29000);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFDA8359),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: const Color(0xFFDA8359)),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              ),
        ),
        title: Text(
          'Giỏ Hàng',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: const Color(0xFFDA8359),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Xóa Giỏ Hàng',
              style: TextStyle(color: const Color(0xFFDA8359), fontSize: 14),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Delivery/Pickup Options
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              'Phương Thức:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            _buildOptionButton('Mang Về', isDelivery, () {
                              setState(() {
                                isDelivery = true;
                              });
                            }),
                            SizedBox(width: 8),
                            _buildOptionButton('Tại Quán', !isDelivery, () {
                              setState(() {
                                isDelivery = false;
                              });
                            }),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    // Store Selection
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              'MANG RA TAI',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedStore?.name ?? '',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            selectedStore?.fullAddress ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _showStoreSelection,
                                      child: Text(
                                        'Thay Đổi',
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Time Selection
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        leading: Icon(
                          Icons.access_time,
                          color: theme.primaryColor,
                        ),
                        title: Text('Hôm nay | Trong 15 phút'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ),

                    SizedBox(height: 8),

                    // Order Notes
                    Container(
                      color: Colors.white,
                      child: ListTile(
                        leading: Icon(
                          Icons.note_alt_outlined,
                          color: Colors.grey,
                        ),
                        title: Text(
                          'Ghi Chú Đơn Hàng',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {},
                      ),
                    ),

                    SizedBox(height: 16),

                    // Product List Container
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  'Danh Sách Sản Phẩm',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Spacer(),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Thêm Sản Phẩm',
                                    style: TextStyle(color: theme.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildProductItem(
                            'Freeze Trà Xanh',
                            'S',
                            55000,
                            freezeQuantity,
                            (quantity) {
                              setState(() {
                                freezeQuantity = quantity;
                              });
                            },
                          ),
                          _buildProductItem(
                            'Phin Sữa Đá',
                            'S',
                            29000,
                            cheeseQuantity,
                            (quantity) {
                              setState(() {
                                cheeseQuantity = quantity;
                              });
                            },
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  'Tạm Tính',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  'Khuyến Mãi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Thêm Khuyến Mãi',
                                    style: TextStyle(color: theme.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  'Tổng Cộng',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Fixed bottom bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                32,
              ), // Thêm padding bottom để tránh notch
              child: Row(
                children: [
                  // Payment options
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.primaryColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.credit_card,
                              color: theme.primaryColor,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Thẻ Nội Địa',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  // Order button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'ĐẶT HÀNG (${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.white,
          border: Border.all(
            color: theme.primaryColor.withOpacity(isSelected ? 1 : 0.3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(
    String name,
    String size,
    int price,
    int quantity,
    Function(int) onQuantityChanged,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: theme.primaryColor),
                  onPressed: () {
                    if (quantity > 1) onQuantityChanged(quantity - 1);
                  },
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                ),
                SizedBox(width: 8),
                Text(
                  quantity.toString(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.add, color: theme.primaryColor),
                  onPressed: () => onQuantityChanged(quantity + 1),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  size,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(price * quantity).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showStoreSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn Cửa Hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              ...stores
                  .map(
                    (store) => ListTile(
                      title: Text(store.name),
                      subtitle: Text(store.fullAddress),
                      leading: Radio<Store>(
                        value: store,
                        groupValue: selectedStore,
                        onChanged: (Store? value) {
                          setState(() {
                            selectedStore = value;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      onTap: () {
                        setState(() {
                          selectedStore = store;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      },
    );
  }
}
