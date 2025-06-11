import 'package:flutter/material.dart';
// cửa hàng
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> stores = [
    {
      'name': 'Hai Ba Trung HP',
      'address': '118-120 Hai Ba Trung\nP. An Bien, Q. Le Chan',
      'phone': '0225 7300557',
      'status': 'Mở',
      'hours': '07:00-23:00',
    },
    {
      'name': 'Nga 5 Cat Bi HP',
      'address': 'Thua So 3, Lo 22B, Khu Do Thi Moi Nga 5 S...\nP. Dong Khe, Q. Ngo Quyen',
      'phone': '0225 7300923',
      'status': 'Mở',
      'hours': '07:00-23:00',
    },
    {
      'name': '957 Ng Tat Thanh DNG',
      'address': '957 Nguyễn Tất Thành\nP. Xuan Ha, Q. Thanh Khe',
      'phone': '0236 730 2500',
      'status': 'Mở',
      'hours': '07:00-23:00',
    },
    {
      'name': 'DH Quoc Te Mien Dong',
      'address': 'Đường Nam Kỳ Khởi Nghĩa\nP. Dinh Hoa, TP. Thu Dau Mot',
      'phone': '028 7300 0250',
      'status': 'Mở',
      'hours': '07:00-19:00',
    },
    {
      'name': 'Petrowaco Lang Ha HN',
      'address': 'Tòa Petrowaco, 97-99 đường Láng Hạ\nP. Lang Ha, Q. Dong Da',
      'phone': '024 56780042',
      'status': 'Mở',
      'hours': '07:00-23:00',
    },
    {
      'name': 'Vincom Center Đồng Khởi',
      'address': '72 Lê Thánh Tôn, Bến Nghé, Q.1, TP.HCM',
      'phone': '028 3827 0300',
      'status': 'Mở',
      'hours': '08:00-22:00',
    },
    {
      'name': 'Aeon Mall Hà Đông',
      'address': 'Tầng 1, Aeon Mall Hà Đông, P. Dương Nội, Q. Hà Đông, Hà Nội',
      'phone': '024 7300 8899',
      'status': 'Mở',
      'hours': '09:00-22:00',
    },
    {
      'name': 'Big C Đà Nẵng',
      'address': '255-257 Hùng Vương, Q. Thanh Khê, Đà Nẵng',
      'phone': '0236 378 9999',
      'status': 'Mở',
      'hours': '08:00-22:00',
    },
    {
      'name': 'Vincom Plaza Cần Thơ',
      'address': '209 30 Tháng 4, P. Xuân Khánh, Q. Ninh Kiều, Cần Thơ',
      'phone': '0292 730 6868',
      'status': 'Mở',
      'hours': '08:00-22:00',
    },
    {
      'name': 'Lotte Mart Nha Trang',
      'address': '58 Đường 23/10, P. Phương Sơn, TP. Nha Trang',
      'phone': '0258 388 7777',
      'status': 'Mở',
      'hours': '08:00-22:00',
    },
    {
      'name': 'Vincom Plaza Biên Hòa',
      'address': '1096 Phạm Văn Thuận, P. Tân Mai, TP. Biên Hòa',
      'phone': '0251 391 8888',
      'status': 'Mở',
      'hours': '08:00-22:00',
    },
    {
      'name': 'Royal City Hà Nội',
      'address': '72A Nguyễn Trãi, Q. Thanh Xuân, Hà Nội',
      'phone': '024 6664 8888',
      'status': 'Mở',
      'hours': '09:00-22:00',
    },
  ];

  List<Map<String, String>> get filteredStores {
    if (_searchQuery.isEmpty) return stores;
    return stores
        .where((store) => store['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA10F1A),
        title: const Text(
          'Cửa Hàng',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm Địa Chỉ',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.map_outlined),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: filteredStores.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final store = filteredStores[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/hg_coffee_logo.png.jpg',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              child: const Icon(Icons.store, size: 36, color: Colors.brown),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                store['address']!,
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    store['phone']!,
                                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      store['status']!,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    store['hours']!,
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 