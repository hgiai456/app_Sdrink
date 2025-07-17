import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['ĐẶT HÀNG', 'CÀI ĐẶT', 'HOÀN TIỀN', 'THANH TOÁN'];

  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Làm cách nào để đặt hàng?',
      answer: 'Chi tiết hướng dẫn đặt hàng...',
    ),
    FAQItem(
      question: 'Tại sao ứng dụng yêu cầu vị trí?',
      answer: 'Chúng tôi cần vị trí của bạn để...',
    ),
    FAQItem(
      question: 'Những phương thức thanh toán nào được chấp nhận?',
      answer: 'Chúng tôi chấp nhận các phương thức thanh toán...',
    ),
    FAQItem(
      question: 'Làm cách nào để nhận món tại cửa hàng?',
      answer: 'Để nhận món tại cửa hàng...',
    ),
    FAQItem(
      question:
          'Các hình thức nhận món khi đặt hàng trên ứng dụng là gì? Có giao hàng tận nơi không?',
      answer: 'Các hình thức nhận món bao gồm...',
    ),
    FAQItem(
      question: 'Có thể dùng thẻ quà tặng hoặc mã giảm giá khi đặt hàng không?',
      answer: 'Có, bạn có thể sử dụng thẻ quà tặng...',
    ),
    FAQItem(
      question: 'Có thể lên lịch nhận thức uống không?',
      answer: 'Có, bạn có thể đặt lịch nhận thức uống...',
    ),
    FAQItem(
      question:
          'Nên làm gì nếu đã thanh toán qua thẻ nhưng đơn hàng không được tạo?',
      answer: 'Trong trường hợp này, bạn vui lòng...',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF383838)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Câu Hỏi Thường Gặp', style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _tabs.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: FilterChip(
                      selected: _selectedTabIndex == index,
                      label: Text(_tabs[index]),
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedTabIndex = index;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFF5F5F5),
                      labelStyle: TextStyle(
                        color:
                            _selectedTabIndex == index
                                ? theme.primaryColor
                                : Color(0xFF808080),
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color:
                              _selectedTabIndex == index
                                  ? theme.primaryColor
                                  : Color(0xFF808080),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _faqItems.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: Text(
                    _faqItems[index].question,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF383838),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_down),
                  iconColor: const Color(0xFF383838),
                  collapsedIconColor: const Color(0xFF383838),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _faqItems[index].answer,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
