import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // #F5F5F5
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ), // #4B2B1B, kiểu iOS
          onPressed: () {
            Navigator.pop(context); // Tùy chọn, có thể bỏ
          },
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Tìm Kiếm Tên Món Ăn',
            hintStyle: TextStyle(
              color: Theme.of(context).inputDecorationTheme.labelStyle?.color,
            ), // #4B2B1B
            border: Theme.of(context).inputDecorationTheme.border,
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            filled: true,
            fillColor: Colors.white, // Khớp với hình
            suffixIcon: Icon(
              Icons.search,
              color: Theme.of(context).inputDecorationTheme.labelStyle?.color,
            ), // #4B2B1B
          ),
        ),
        actions: [], // Không có icon trạng thái
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor, // #F5F5F5
        child: Center(
          child: Text(
            'Nội dung tìm kiếm sẽ được thêm sau',
            style:
                Theme.of(
                  context,
                ).textTheme.bodyLarge, // Sử dụng style bodyLarge
          ),
        ),
      ),
    );
  }
}
