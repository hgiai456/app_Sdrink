import 'package:app_selldrinks/components/product_item.dart';
import 'package:app_selldrinks/models/Product.dart';
import 'package:app_selldrinks/screens/home_screen.dart';
import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Product> products = [
    Product(
      id: 1,
      name: 'Phin sữa đá',
      description:
          'hương vị cà phê Việt Nam đích thực! Từng hạt cà phê hảo hạng được chọn bằng tay, phối trộn độc đáo giữa hạt Robusta từ cao nguyên Việt Nam, thêm Arabica thơm lừng',
      price: 35000,
      imageUrl:
          'assets/images/phin-sua-da-eae59734-6d54-471e-a34f-7ffe0fb68e6c.webp',
      badge: "BÁN CHẠY!",
    ),
    Product(
      id: 2,
      name: 'Phin đen đá',
      description:
          'hương vị cà phê Việt Nam đích thực! Từng hạt cà phê hảo hạng được chọn bằng tay, phối trộn độc đáo giữa hạt Robusta từ cao nguyên Việt Nam, thêm Arabica thơm lừng',
      price: 30000,
      imageUrl: 'assets/images/phin-den-da.webp',
      badge: "BÁN CHẠY!",
    ),
    Product(
      id: 3,
      name: 'Americano',
      description:
          'hương vị cà phê Việt Nam đích thực! Từng hạt cà phê hảo hạng được chọn bằng tay, phối trộn độc đáo giữa hạt Robusta từ cao nguyên Việt Nam, thêm Arabica thơm lừng',
      price: 35000,
      imageUrl: 'assets/images/americano.webp',
      badge: "BÁN CHẠY!",
    ),

    Product(
      id: 4,
      name: 'Americano',
      description:
          'hương vị cà phê Việt Nam đích thực! Từng hạt cà phê hảo hạng được chọn bằng tay, phối trộn độc đáo giữa hạt Robusta từ cao nguyên Việt Nam, thêm Arabica thơm lừng',
      price: 35000,
      imageUrl: 'assets/images/americano.webp',
      badge: "BÁN CHẠY!",
    ),
    Product(
      id: 5,
      name: 'Americano',
      description:
          'hương vị cà phê Việt Nam đích thực! Từng hạt cà phê hảo hạng được chọn bằng tay, phối trộn độc đáo giữa hạt Robusta từ cao nguyên Việt Nam, thêm Arabica thơm lừng',
      price: 35000,
      imageUrl: 'assets/images/americano.webp',
      badge: "BÁN CHẠY!",
    ),
    Product(
      id: 6,
      name: 'Americano',
      description:
          'hương vị cà phê Việt Nam đích thực! Từng hạt cà phê hảo hạng được chọn bằng tay, phối trộn độc đáo giữa hạt Robusta từ cao nguyên Việt Nam, thêm Arabica thơm lừng',
      price: 35000,
      imageUrl: 'assets/images/americano.webp',
      badge: "BÁN CHẠY!",
    ),
    Product(
      id: 7,
      name: 'Americano',
      description:
          'hương vị cà phê Việt Nam đích thực! Từng hạt cà phê hảo hạng được chọn bằng tay, phối trộn độc đáo giữa hạt Robusta từ cao nguyên Việt Nam, thêm Arabica thơm lừng',
      price: 35000,
      imageUrl: 'assets/images/americano.webp',
      badge: "BÁN CHẠY!",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          }, //Xử lý khi CLick
        ),
        title: Text(
          "Cà phê truyền thống",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium!.color, // #4B2B1B
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              //Xử lý sự kiện click
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.tune,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.apps,
                    size: 20,
                    color: Theme.of(context).iconTheme.color, // #4B2B1B
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            //Danh sách sản phẩm
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductItem(
                  product: products[index],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã chọn ${products[index].name}'),
                        backgroundColor: Theme.of(context).primaryColor,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      //Button đặt hàng
      bottomSheet: Container(
        height: 60,
        color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mang Về',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    '35 Thang Long Tan Binh HCMC',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 14,
                    ), // Sử dụng style từ theme
                  ), //Địa chỉ cửa hàng đã chọn
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
