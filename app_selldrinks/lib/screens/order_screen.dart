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
    {'name': 'KEMDI', 'image': 'assets/danh_muc.png'},
    {'name': 'CÀ PHÊ TRUYỀN THỦY', 'image': 'assets/danh_muc.png'},
    {'name': 'CÀ PHÊ PHÁ MAY', 'image': 'assets/danh_muc.png'},
    {'name': 'TRÀ ĐÀO CAM SẢ', 'image': 'assets/danh_muc.png'},
    {'name': 'BÁNH MÌ ĐẶC BIỆT', 'image': 'assets/danh_muc.png'},
    {'name': 'NƯỚC ÉP TỎI', 'image': 'assets/danh_muc.png'},
    {'name': 'TRÁI CÂY DẺO', 'image': 'assets/danh_muc.png'},
    {'name': 'SỮA CHUA HY LẠP', 'image': 'assets/danh_muc.png'},
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
        'image': 'assets/test.png',
      },
      {
        'name': 'Kemdi Sô cô la',
        'description':
            'Ngọt dịu, hòa quyện với vị chocolate vani thơm béo, hợp cho những ngày...',
        'price': '39,000 đ',
        'code': 'DK5001',
        'status': 'CÒN HÀNG',
        'image': 'assets/test2.png',
      },
      {
        'name': 'Kemdi Bánh Quy',
        'description': 'Béo bùi, giòn rụm, đỗc đáo từ bánh quy hòa cùng kem...',
        'price': '39,000 đ',
        'code': 'DK5002',
        'status': 'HẾT HÀNG',
        'image': 'assets/san_pham.png',
      },
    ],
    'CÀ PHÊ TRUYỀN THỦY': [
      {
        'name': 'Cà Phê Sữa Đá',
        'description': 'Hương vị truyền thống đậm đà, béo ngậy...',
        'price': '35,000 đ',
        'code': 'CP001',
        'status': 'CÒN HÀNG',
        'image': 'assets/san_pham.png',
      },
    ],
    'CÀ PHÊ PHÁ MAY': [
      {
        'name': 'Cà Phê Đen Đá',
        'description': 'Đen đặc, đậm vị, không đường...',
        'price': '33,000 đ',
        'code': 'CP002',
        'status': 'CÒN HÀNG',
        'image': 'assets/san_pham.png',
      },
    ],
    'TRÀ ĐÀO CAM SẢ': [
      {
        'name': 'Trà Đào Cam Sả',
        'description': 'Thơm ngon, tươi mát, vị chua nhẹ...',
        'price': '40,000 đ',
        'code': 'TRA001',
        'status': 'CÒN HÀNG',
        'image': 'assets/san_pham.png',
      },
    ],
    'BÁNH MÌ ĐẶC BIỆT': [
      {
        'name': 'Bánh Mì Đặc Biệt',
        'description': 'Bánh mì giòn, pate béo ngậy...',
        'price': '45,000 đ',
        'code': 'PHI001',
        'status': 'CÒN HÀNG',
        'image': 'assets/san_pham.png',
      },
    ],
    'NƯỚC ÉP TỎI': [
      {
        'name': 'Nước Ép Tỏi',
        'description': 'Tỏi tươi ép, tốt cho sức khỏe...',
        'price': '30,000 đ',
        'code': 'NE001',
        'status': 'CÒN HÀNG',
        'image': 'assets/san_pham.png',
      },
    ],
    'TRÁI CÂY DẺO': [
      {
        'name': 'Trái Cây Dẻo',
        'description': 'Trái cây sấy dẻo, ngọt tự nhiên...',
        'price': '25,000 đ',
        'code': 'TCD001',
        'status': 'CÒN HÀNG',
        'image': 'assets/san_pham.png',
      },
    ],
    'SỮA CHUA HY LẠP': [
      {
        'name': 'Sữa Chua Hy Lạp',
        'description': 'Béo ngậy, giàu protein...',
        'price': '50,000 đ',
        'code': 'SCHL001',
        'status': 'CÒN HÀNG',
        'image': 'assets/san_pham.png',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
          child: TextField(
            enabled: false,
            decoration: InputDecoration(
              hintText: 'Tìm Kiếm Tên Món Ăn',
              hintStyle: TextStyle(
                color: Theme.of(context).inputDecorationTheme.labelStyle?.color,
              ),
              border: Theme.of(context).inputDecorationTheme.border,
              focusedBorder:
                  Theme.of(context).inputDecorationTheme.focusedBorder,
              filled: true,
              fillColor: Colors.white,
              suffixIcon: Icon(
                Icons.search,
                color: Theme.of(context).inputDecorationTheme.labelStyle?.color,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Thay thế phần danh mục sản phẩm (vuốt ngang)
          SizedBox(
            height: 120, // Tăng chiều cao để chứa 2 hàng văn bản
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(categories.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 100, // Tăng chiều cao container để chứa văn bản
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                AssetImage(categories[index]['image']!)
                                    as ImageProvider,
                            backgroundColor: Colors.grey[200],
                          ),
                          SizedBox(height: 4),
                          Expanded(
                            // Sử dụng Expanded thay Flexible để co giãn tự nhiên
                            child: Text(
                              categories[index]['name']!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    _selectedCategoryIndex == index
                                        ? Theme.of(context).primaryColor
                                        : null,
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
