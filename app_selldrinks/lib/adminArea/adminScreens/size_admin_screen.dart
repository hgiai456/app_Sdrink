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
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1;
  int totalPage = 1;
  List<SizeAdmin> sizes = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchAllSizes(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMoreData) {
        loadMoreSizes();
      }
    }
  }

  Future<void> fetchAllSizes({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        isLoading = true;
        currentPage = 1;
        sizes.clear();
        hasMoreData = true;
      });
    }

    try {
      final result = await SizeAdminService.fetchSizes(
        widget.token,
        currentPage,
      );

      setState(() {
        if (refresh) {
          sizes = result['sizes'];
        } else {
          sizes.addAll(result['sizes']);
        }
        totalPage = result['totalPage'];
        hasMoreData = currentPage < totalPage;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
    }
  }

  Future<void> loadMoreSizes() async {
    if (currentPage >= totalPage) return;

    setState(() {
      isLoadingMore = true;
      currentPage++;
    });

    await fetchAllSizes();
  }

  Future<void> _refreshData() async {
    await fetchAllSizes(refresh: true);
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
              padding: const EdgeInsets.all(24),
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
                        filled: true,
                        fillColor: kWhite,
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
                              _refreshData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    size == null
                                        ? '✅ Thêm size thành công!'
                                        : '✅ Cập nhật size thành công!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    size == null
                                        ? '❌ Thêm size thất bại!'
                                        : '❌ Cập nhật size thất bại!',
                                  ),
                                  backgroundColor: Colors.red,
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

  Future<void> deleteSize(SizeAdmin size) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text('Bạn có chắc chắn muốn xóa size "${size.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final success = await SizeAdminService.deleteSize(size.id!, widget.token);
      if (success) {
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Xóa size thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Xóa size thất bại!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý size', style: TextStyle(color: kDarkGray)),
        backgroundColor: kWhite,
        iconTheme: IconThemeData(color: kDarkGray),
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: kDarkGray),
            onPressed: _refreshData,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      backgroundColor: kLightGray,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: kDarkGray,
        child:
            isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: kDarkGray),
                      const SizedBox(height: 16),
                      Text(
                        'Đang tải dữ liệu...',
                        style: TextStyle(color: kMediumGray),
                      ),
                    ],
                  ),
                )
                : sizes.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.straighten, size: 64, color: kMediumGray),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có size nào!',
                        style: TextStyle(
                          fontSize: 18,
                          color: kMediumGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhấn nút + để thêm size mới',
                        style: TextStyle(color: kMediumGray),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: sizes.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == sizes.length) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(color: kDarkGray),
                      );
                    }

                    final size = sizes[index];
                    return Card(
                      color: kWhite,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: kDarkGray.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.straighten, color: kDarkGray),
                        ),
                        title: Text(
                          size.name,
                          style: TextStyle(
                            color: kDarkGray,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle:
                            size.createdAt != null
                                ? Text(
                                  'Tạo: ${size.createdAt.toString().split('.')[0]}',
                                  style: TextStyle(
                                    color: kMediumGray,
                                    fontSize: 12,
                                  ),
                                )
                                : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: kDarkGray),
                              onPressed: () => showSizeDialog(size: size),
                              tooltip: 'Chỉnh sửa',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteSize(size),
                              tooltip: 'Xóa',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSizeDialog(),
        backgroundColor: kDarkGray,
        child: Icon(Icons.add, color: kWhite),
        tooltip: 'Thêm size mới',
      ),
    );
  }
}
