import 'package:flutter/material.dart';
import 'package:app_selldrinks/adminArea/adminModels/prodetail_admin.dart';
import 'package:app_selldrinks/adminArea/adminSevices/prodetail_admin_service.dart';
import 'package:app_selldrinks/adminArea/adminSevices/product_admin_service.dart';
import 'package:app_selldrinks/adminArea/adminModels/product_admin.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';

class ProdetailAdminScreen extends StatefulWidget {
  final String token;
  const ProdetailAdminScreen({Key? key, required this.token}) : super(key: key);

  @override
  _ProdetailAdminScreenState createState() => _ProdetailAdminScreenState();
}

class _ProdetailAdminScreenState extends State<ProdetailAdminScreen> {
  int currentPage = 1;
  int totalPage = 1;
  List<ProdetailAdmin> prodetails = [];
  List<ProductAdmin> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllProdetails();
    fetchProducts();
  }

  Future<void> fetchAllProdetails({int page = 1}) async {
    setState(() => isLoading = true);
    try {
      final result = await ProdetailAdminService.fetchProdetails(
        widget.token,
        page,
      );
      prodetails = result['prodetails'];
      currentPage = result['currentPage'];
      totalPage = result['totalPage'];
    } catch (e) {}
    setState(() => isLoading = false);
  }

  Future<void> fetchProducts() async {
    try {
      final result = await ProductAdminService.fetchProducts(widget.token, 1);
      setState(() {
        products = result['products'];
      });
    } catch (e) {}
  }

  void showProdetailDialog({ProdetailAdmin? prodetail}) {
    final nameController = TextEditingController(text: prodetail?.name ?? '');
    int? selectedProductId = prodetail?.productId;
    final sizeIdController = TextEditingController(
      text: prodetail?.sizeId.toString() ?? '',
    );
    final priceController = TextEditingController(
      text: prodetail?.price.toString() ?? '',
    );
    final oldpriceController = TextEditingController(
      text: prodetail?.oldprice?.toString() ?? '',
    );
    final quantityController = TextEditingController(
      text: prodetail?.quantity.toString() ?? '',
    );
    final specificationController = TextEditingController(
      text: prodetail?.specification ?? '',
    );
    final img1Controller = TextEditingController(text: prodetail?.img1 ?? '');
    final img2Controller = TextEditingController(text: prodetail?.img2 ?? '');
    final img3Controller = TextEditingController(text: prodetail?.img3 ?? '');
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: kLightGray,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        prodetail == null
                            ? 'Thêm chi tiết sản phẩm'
                            : 'Sửa chi tiết sản phẩm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: kDarkGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Không được để trống'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedProductId,
                        decoration: InputDecoration(
                          labelText: 'Sản phẩm',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items:
                            products
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p.id,
                                    child: Text(p.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          selectedProductId = val;
                        },
                        validator: (v) => v == null ? 'Chọn sản phẩm' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: sizeIdController,
                        decoration: InputDecoration(
                          labelText: 'Size ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Không được để trống'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Giá',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Không được để trống'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: oldpriceController,
                        decoration: InputDecoration(
                          labelText: 'Giá cũ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: quantityController,
                        decoration: InputDecoration(
                          labelText: 'Số lượng',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Không được để trống'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: specificationController,
                        decoration: InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: img1Controller,
                        decoration: InputDecoration(
                          labelText: 'Ảnh 1',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: img2Controller,
                        decoration: InputDecoration(
                          labelText: 'Ảnh 2',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: img3Controller,
                        decoration: InputDecoration(
                          labelText: 'Ảnh 3',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                color: kMediumGray,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kDarkGray,
                              foregroundColor: kWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              final newProdetail = ProdetailAdmin(
                                id: prodetail?.id,
                                name: nameController.text,
                                productId: selectedProductId!,
                                sizeId:
                                    int.tryParse(sizeIdController.text) ?? 0,
                                price: int.tryParse(priceController.text) ?? 0,
                                oldprice: int.tryParse(oldpriceController.text),
                                quantity:
                                    int.tryParse(quantityController.text) ?? 0,
                                specification: specificationController.text,
                                img1: img1Controller.text,
                                img2: img2Controller.text,
                                img3: img3Controller.text,
                              );
                              bool success = false;
                              if (prodetail == null) {
                                success =
                                    await ProdetailAdminService.addProdetail(
                                      newProdetail,
                                      widget.token,
                                    );
                              } else {
                                success =
                                    await ProdetailAdminService.updateProdetail(
                                      newProdetail,
                                      widget.token,
                                    );
                              }
                              if (success) {
                                Navigator.pop(context);
                                fetchAllProdetails(page: currentPage);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      prodetail == null
                                          ? 'Thêm chi tiết thất bại!'
                                          : 'Cập nhật chi tiết thất bại!',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              prodetail == null ? 'Thêm' : 'Cập nhật',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Future<void> deleteProdetail(int id) async {
    await ProdetailAdminService.deleteProdetail(id, widget.token);
    fetchAllProdetails(page: currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý chi tiết sản phẩm',
          style: TextStyle(color: kDarkGray),
        ),
        backgroundColor: kWhite,
        iconTheme: IconThemeData(color: kDarkGray),
      ),
      backgroundColor: kLightGray,
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: kDarkGray))
              : Column(
                children: [
                  Expanded(
                    child:
                        prodetails.isEmpty
                            ? Center(
                              child: Text(
                                'Không có chi tiết nào!',
                                style: TextStyle(color: kMediumGray),
                              ),
                            )
                            : ListView.builder(
                              itemCount: prodetails.length,
                              itemBuilder: (_, i) {
                                final p = prodetails[i];
                                return Card(
                                  color: kWhite,
                                  child: ListTile(
                                    title: Text(
                                      p.name,
                                      style: TextStyle(color: kDarkGray),
                                    ),
                                    subtitle: Text(
                                      'Giá: ${p.price}đ, Số lượng: ${p.quantity}',
                                      style: TextStyle(color: kMediumGray),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: kDarkGray,
                                          ),
                                          onPressed:
                                              () => showProdetailDialog(
                                                prodetail: p,
                                              ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => deleteProdetail(p.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                  buildPagination(),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showProdetailDialog(),
        child: Icon(Icons.add, color: kWhite),
        backgroundColor: kDarkGray,
      ),
    );
  }

  Widget buildPagination() {
    List<Widget> pages = [];
    int start = (currentPage - 2 > 0) ? currentPage - 2 : 1;
    int end = (currentPage + 2 < totalPage) ? currentPage + 2 : totalPage;

    if (start > 1) {
      pages.add(pageButton(1));
      if (start > 2) pages.add(Text('...'));
    }
    for (int i = start; i <= end; i++) {
      pages.add(pageButton(i));
    }
    if (end < totalPage) {
      if (end < totalPage - 1) pages.add(Text('...'));
      pages.add(pageButton(totalPage));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed:
              currentPage > 1
                  ? () => fetchAllProdetails(page: currentPage - 1)
                  : null,
        ),
        ...pages,
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed:
              currentPage < totalPage
                  ? () => fetchAllProdetails(page: currentPage + 1)
                  : null,
        ),
      ],
    );
  }

  Widget pageButton(int page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: page == currentPage ? kDarkGray : kWhite,
          foregroundColor: page == currentPage ? kWhite : kDarkGray,
          minimumSize: Size(36, 36),
          padding: EdgeInsets.zero,
        ),
        onPressed:
            page == currentPage ? null : () => fetchAllProdetails(page: page),
        child: Text('$page'),
      ),
    );
  }
}
