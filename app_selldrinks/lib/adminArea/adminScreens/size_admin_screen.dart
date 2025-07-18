import 'package:flutter/material.dart';
import 'package:app_selldrinks/adminArea/adminModels/size_admin.dart';
import 'package:app_selldrinks/adminArea/adminSevices/size_admin_service.dart';

class SizeAdminScreen extends StatefulWidget {
  final String token;
  const SizeAdminScreen({Key? key, required this.token}) : super(key: key);

  @override
  _SizeAdminScreenState createState() => _SizeAdminScreenState();
}

class _SizeAdminScreenState extends State<SizeAdminScreen> {
  int currentPage = 1;
  int totalPage = 1;
  List<SizeAdmin> sizes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllSizes();
  }

  Future<void> fetchAllSizes({int page = 1}) async {
    setState(() => isLoading = true);
    try {
      final result = await SizeAdminService.fetchSizes(widget.token, page);
      sizes = result['sizes'];
      currentPage = result['currentPage'];
      totalPage = result['totalPage'];
    } catch (e) {
      // Xử lý lỗi
    }
    setState(() => isLoading = false);
  }

  void showSizeDialog({SizeAdmin? size}) {
    final nameController = TextEditingController(text: size?.name ?? '');
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(size == null ? 'Thêm size' : 'Sửa size'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Tên size'),
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Không được để trống'
                                  : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final newSize = SizeAdmin(
                    id: size?.id,
                    name: nameController.text,
                  );
                  bool success = false;
                  if (size == null) {
                    success = await SizeAdminService.addSize(
                      newSize,
                      widget.token,
                    );
                  } else {
                    success = await SizeAdminService.updateSize(
                      newSize,
                      widget.token,
                    );
                  }
                  if (success) {
                    Navigator.pop(context);
                    fetchAllSizes(page: currentPage);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          size == null
                              ? 'Thêm size thất bại!'
                              : 'Cập nhật size thất bại!',
                        ),
                      ),
                    );
                  }
                },
                child: Text(size == null ? 'Thêm' : 'Cập nhật'),
              ),
            ],
          ),
    );
  }

  Future<void> deleteSize(int id) async {
    await SizeAdminService.deleteSize(id, widget.token);
    fetchAllSizes(page: currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý size')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child:
                        sizes.isEmpty
                            ? Center(child: Text('Không có size nào!'))
                            : ListView.builder(
                              itemCount: sizes.length,
                              itemBuilder: (_, i) {
                                final s = sizes[i];
                                return ListTile(
                                  leading: Icon(Icons.straighten),
                                  title: Text(s.name),
                                  subtitle:
                                      s.createdAt != null
                                          ? Text('Tạo: ${s.createdAt}')
                                          : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed:
                                            () => showSizeDialog(size: s),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () => deleteSize(s.id!),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                  buildPagination(),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSizeDialog(),
        child: Icon(Icons.add),
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
                  ? () => fetchAllSizes(page: currentPage - 1)
                  : null,
        ),
        ...pages,
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed:
              currentPage < totalPage
                  ? () => fetchAllSizes(page: currentPage + 1)
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
          backgroundColor: page == currentPage ? Colors.blue : Colors.white,
          foregroundColor: page == currentPage ? Colors.white : Colors.black,
          minimumSize: Size(36, 36),
          padding: EdgeInsets.zero,
        ),
        onPressed: page == currentPage ? null : () => fetchAllSizes(page: page),
        child: Text('$page'),
      ),
    );
  }
}
