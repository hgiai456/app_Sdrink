import 'package:app_selldrinks/screens/prod_detail_screen.dart';
import 'package:app_selldrinks/screens/search_screen.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int _selectedCategoryIndex = 0;

  // Dữ liệu ảo cho các danh mục với hình ảnh
  final List<Map<String, String>> categories = [
    {'name': 'CÀ PHÊ TRUYỀN THỦY', 'image': 'assets/images/danh_muc.png'},
    {'name': 'CÀ PHÊ PHÁ MAY', 'image': 'assets/images/danh_muc.png'},
    {'name': 'TRÀ ĐÀO CAM SẢ', 'image': 'assets/images/danh_muc.png'},
    {'name': 'BÁNH MÌ ĐẶC BIỆT', 'image': 'assets/images/danh_muc.png'},
    {'name': 'NƯỚC ÉP TỎI', 'image': 'assets/images/danh_muc.png'},
    {'name': 'TRÁI CÂY DẺO', 'image': 'assets/images/danh_muc.png'},
    {'name': 'SỮA CHUA HY LẠP', 'image': 'assets/images/danh_muc.png'},
  ];

  // Dữ liệu ảo cho sản phẩm với hình ảnh
  final Map<String, List<Map<String, String>>> products = {
    'KEMDI': [
      {
        'name': 'Kemdi Affogato',
        'description':
            'Kemdi Affogato được gắn với cà phê Highlands với vị kem đậm đà, ngậy...',
        'price': '39,000 đ',
        'code': 'DK5003',
        'status': 'HẾT HÀNG',
        'image': 'assets/images/san_pham.png',
      },
      {
        'name': 'Kemdi Sô cô la',
        'description':
            'Ngọt dịu, hòa quyện với vị chocolate vani thơm béo, hợp cho những ngày...',
        'price': '39,000 đ',
        'code': 'DK5001',
        'status': 'CÒN HÀNG',
        'image': 'assets/images/test2.png',
      },
      {
        'name': 'Kemdi Bánh Quy',
        'description': 'Béo bùi, giòn rụm, đỗc đáo từ bánh quy hòa cùng kem...',
        'price': '39,000 đ',
        'code': 'DK5002',
        'status': 'HẾT HÀNG',
        'image': 'assets/images/san_pham.png',
      },
    ],
    'CÀ PHÊ TRUYỀN THỦY': [
      {
        'name': 'Cà Phê Sữa Đá',
        'description': 'Hương vị truyền thống đậm đà, béo ngậy...',
        'price': '35,000 đ',
        'code': 'CP001',
        'status': 'CÒN HÀNG',
        'image': 'assets/images/san_pham.png',
      },
    ],
    'CÀ PHÊ PHÁ MAY': [
      {
        'name': 'Cà Phê Đen Đá',
        'description': 'Đen đặc, đậm vị, không đường...',
        'price': '33,000 đ',
        'code': 'CP002',
        'status': 'CÒN HÀNG',
        'image': 'assets/images/san_pham.png',
      },
    ],
    'TRÀ ĐÀO CAM SẢ': [
      {
        'name': 'Trà Đào Cam Sả',
        'description': 'Thơm ngon, tươi mát, vị chua nhẹ...',
        'price': '40,000 đ',
        'code': 'TRA001',
        'status': 'CÒN HÀNG',
        'image': 'assets/images/san_pham.png',
      },
    ],
    'BÁNH MÌ ĐẶC BIỆT': [
      {
        'name': 'Bánh Mì Đặc Biệt',
        'description': 'Bánh mì giòn, pate béo ngậy...',
        'price': '45,000 đ',
        'code': 'PHI001',
        'status': 'CÒN HÀNG',
        'image': 'assets/images/san_pham.png',
      },
    ],
    'NƯỚC ÉP TỎI': [
      {
        'name': 'Nước Ép Tỏi',
        'description': 'Tỏi tươi ép, tốt cho sức khỏe...',
        'price': '30,000 đ',
        'code': 'NE001',
        'status': 'CÒN HÀNG',
        'image': 'assets/images/san_pham.png',
      },
    ],
    'TRÁI CÂY DẺO': [
      {
        'name': 'Trái Cây Dẻo',
        'description': 'Trái cây sấy dẻo, ngọt tự nhiên...',
        'price': '25,000 đ',
        'code': 'TCD001',
        'status': 'CÒN HÀNG',
        'image': 'assets/images/san_pham.png',
      },
    ],
    'SỮA CHUA HY LẠP': [
      {
        'name': 'Sữa Chua Hy Lạp',
        'description': 'Béo ngậy, giàu protein...',
        'price': '50,000 đ',
        'code': 'SCHL001',
        'status': 'CÒN HÀNG',
        'image': 'assets/images/san_pham.png',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },

            child: Container(
              height: 40,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: TextField(
                  enabled: false,
                  textAlignVertical: TextAlignVertical.center, // Add this
                  decoration: InputDecoration(
                    hintText: 'Tìm Kiếm Tên Món Ăn',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ), // Add this
                    hintStyle: TextStyle(
                      color:
                          Theme.of(
                            context,
                          ).inputDecorationTheme.labelStyle?.color,
                    ),
                    border: Theme.of(context).inputDecorationTheme.border,
                    focusedBorder:
                        Theme.of(context).inputDecorationTheme.focusedBorder,
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true, // Căng chữ vào giữa
                    suffixIcon: Icon(
                      Icons.search,
                      color:
                          Theme.of(
                            context,
                          ).inputDecorationTheme.labelStyle?.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // Thay thế phần danh mục sản phẩm (vuốt ngang)
          Container(
            height: 120,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(categories.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Container(
                      width: 90,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                _selectedCategoryIndex == index
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(
                              categories[index]['image']!,
                            ),
                            backgroundColor: Colors.grey[200],
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              categories[index]['name']!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                color:
                                    _selectedCategoryIndex == index
                                        ? Theme.of(context).primaryColor
                                        : Colors.black87,
                                fontSize: 12,
                                fontWeight:
                                    _selectedCategoryIndex == index
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Danh sách sản phẩm theo danh mục đã chọn
          Expanded(
            child: ListView.builder(
              itemCount:
                  products[categories[_selectedCategoryIndex]['name']]!.length,
              itemBuilder: (context, index) {
                final product =
                    products[categories[_selectedCategoryIndex]['name']]![index];
                return ListTile(
                  leading: Image.asset(
                    product['image']!,
                    width: 50,
                    height: 50,
                    errorBuilder:
                        (context, error, stackTrace) => Icon(Icons.error),
                  ),
                  title: Text(
                    product['name']!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    product['description']!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        product['price']!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        product['status']!,
                        style: TextStyle(
                          color:
                              product['status'] == 'HẾT HÀNG'
                                  ? Colors.red
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ProductDetailScreen(
                              name: product['name']!,
                              description: product['description']!,
                              price: product['price']!,
                              status: product['status']!,
                              image: product['image']!,
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
