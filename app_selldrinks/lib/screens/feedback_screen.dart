import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _categoryController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Phản Hồi & Hỗ Trợ',
          style: theme.textTheme.titleLarge?.copyWith(color: Color(0xFF4B2B1B)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chúng mình luôn lắng nghe. Hãy cho chúng mình biết cảm nhận của bạn',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 24),

                // Tên
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên của bạn',
                    suffixText: '*',
                    suffixStyle: TextStyle(color: theme.primaryColor),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Vui lòng nhập tên của bạn';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Số điện thoại
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    suffixText: '*',
                    suffixStyle: TextStyle(color: theme.primaryColor),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Phân loại
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: 'Phân loại',
                    suffixText: '*',
                    suffixStyle: TextStyle(color: theme.primaryColor),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Vui lòng nhập phân loại';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Thông tin
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Thông tin (tối đa 1500 ký tự)',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  maxLength: 1500,
                ),
                const SizedBox(height: 24),

                // Nút Gửi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Xử lý gửi form
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Gửi'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _categoryController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
