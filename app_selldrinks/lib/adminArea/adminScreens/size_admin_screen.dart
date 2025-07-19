import 'package:flutter/material.dart';
import 'package:app_selldrinks/adminArea/adminModels/size_admin.dart';
import 'package:app_selldrinks/adminArea/adminSevices/size_admin_service.dart';
import 'package:app_selldrinks/themes/highland_theme.dart';

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
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: kLightGray,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      size == null ? 'Thêm size' : 'Sửa size',
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
                        labelText: 'Tên size',
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
                  ],
                ),
              ),
            ),
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
      appBar: AppBar(
        title: Text('Quản lý size', style: TextStyle(color: kDarkGray)),
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
                        sizes.isEmpty
                            ? Center(
                              child: Text(
                                'Không có size nào!',
                                style: TextStyle(color: kMediumGray),
                              ),
                            )
                            : ListView.builder(
                              itemCount: sizes.length,
                              itemBuilder: (_, i) {
                                final s = sizes[i];
                                return Card(
                                  color: kWhite,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.straighten,
                                      color: kDarkGray,
                                    ),
                                    title: Text(
                                      s.name,
                                      style: TextStyle(color: kDarkGray),
                                    ),
                                    subtitle:
                                        s.createdAt != null
                                            ? Text(
                                              'Tạo: ${s.createdAt}',
                                              style: TextStyle(
                                                color: kMediumGray,
                                              ),
                                            )
                                            : null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: kDarkGray,
                                          ),
                                          onPressed:
                                              () => showSizeDialog(size: s),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => deleteSize(s.id!),
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
        onPressed: () => showSizeDialog(),
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
