import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Khác
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;

  // Các biến lưu thông tin
  String firstName = '';
  String lastName = '';
  String gender = '';
  String dob = '';
  String phone = '';
  String email = '';

  // Biến lỗi cho từng trường
  bool firstNameError = false;
  bool lastNameError = false;
  bool genderError = false;
  bool dobError = false;
  bool phoneError = false;

  // Controllers cho TextField
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('firstName') ?? '';
      lastName = prefs.getString('lastName') ?? '';
      gender = prefs.getString('gender') ?? '';
      dob = prefs.getString('dob') ?? '';
      phone = prefs.getString('phone') ?? '';
      email = prefs.getString('email') ?? '';

      // Khởi tạo controllers với dữ liệu đã lưu
      firstNameController = TextEditingController(text: firstName);
      lastNameController = TextEditingController(text: lastName);
      phoneController = TextEditingController(text: phone);
      emailController = TextEditingController(text: email);

      // Parse date of birth if exists
      if (dob.isNotEmpty) {
        try {
          selectedDate = DateTime.parse(dob);
        } catch (e) {
          selectedDate = DateTime.now();
        }
      }
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('gender', gender);
    await prefs.setString('dob', dob);
    await prefs.setString('phone', phone);
    await prefs.setString('email', email);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEBE5), // Nâu nhạt
      appBar: AppBar(
        backgroundColor: const Color(0xFFA10F1A), // Đỏ đậm
        title: const Text(
          'Hồ Sơ',
          style: TextStyle(
            fontFamily: 'RobotoSlab',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar, tên, trạng thái, nạp tiền
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFA10F1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(0xFFD32F2F), // Đỏ sáng
                          child: Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Color(0xFFA10F1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'THÀNH VIÊN',
                                style: TextStyle(
                                  fontFamily: 'RobotoSlab',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'DRIPS: 0',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFFA10F1A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Trả Trước: ',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                '0 đ',
                                style: TextStyle(
                                  fontFamily: 'RobotoSlab',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Thông tin chung
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thông Tin Chung',
                    style: TextStyle(
                      fontFamily: 'RobotoSlab',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF4B2B1B),
                    ),
                  ),
                  isEditing
                      ? Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isEditing = false;
                                // Reset lại giá trị controller nếu hủy
                                firstNameController.text = firstName;
                                lastNameController.text = lastName;
                                phoneController.text = phone;
                                emailController.text = email;
                              });
                            },
                            child: const Text(
                              'Hủy',
                              style: TextStyle(
                                fontFamily: 'RobotoSlab',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                        ],
                      )
                      : TextButton(
                        onPressed: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                        child: const Text(
                          'Sửa',
                          style: TextStyle(
                            fontFamily: 'RobotoSlab',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA10F1A),
                          ),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child:
                        isEditing
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildEditField(
                                  controller: firstNameController,
                                  label: 'Tên',
                                ),
                                if (firstNameError)
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 8,
                                      bottom: 4,
                                    ),
                                    child: Text(
                                      '* Vui lòng nhập tên',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                            : _buildInfoField(label: 'Tên', value: firstName),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        isEditing
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildEditField(
                                  controller: lastNameController,
                                  label: 'Họ',
                                ),
                                if (lastNameError)
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 8,
                                      bottom: 4,
                                    ),
                                    child: Text(
                                      '* Vui lòng nhập họ',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                            : _buildInfoField(label: 'Họ', value: lastName),
                  ),
                ],
              ),
              isEditing
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGenderDropdown(),
                      if (genderError)
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 4),
                          child: Text(
                            '* Vui lòng chọn giới tính',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                    ],
                  )
                  : _buildInfoField(label: 'Giới Tính', value: gender),
              isEditing
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDatePicker(),
                      if (dobError)
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 4),
                          child: Text(
                            '* Vui lòng chọn ngày sinh',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                    ],
                  )
                  : _buildInfoField(label: 'Ngày Sinh', value: dob),
              const SizedBox(height: 8),
              const Text(
                'Số Điện Thoại',
                style: TextStyle(
                  fontFamily: 'RobotoSlab',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF4B2B1B),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.flag, color: Colors.red, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '+84',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child:
                                    isEditing
                                        ? TextField(
                                          controller: phoneController,
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 16,
                                            color: Color(0xFF000000),
                                          ),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          keyboardType: TextInputType.phone,
                                        )
                                        : Text(
                                          phone,
                                          style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 16,
                                            color: Color(0xFF000000),
                                          ),
                                        ),
                              ),
                              const Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        if (isEditing && phoneError)
                          const Padding(
                            padding: EdgeInsets.only(left: 8, bottom: 4),
                            child: Text(
                              '* Vui lòng nhập số điện thoại',
                              style: TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Email',
                style: TextStyle(
                  fontFamily: 'RobotoSlab',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF4B2B1B),
                ),
              ),
              const SizedBox(height: 8),
              isEditing
                  ? TextField(
                    controller: emailController,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: Color(0xFF000000),
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  )
                  : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      email,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
              const SizedBox(height: 32),
              // Button Lưu thông tin
              if (isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA10F1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      // Reset lỗi trước khi kiểm tra
                      setState(() {
                        firstNameError =
                            firstNameController.text.trim().isEmpty;
                        lastNameError = lastNameController.text.trim().isEmpty;
                        genderError = gender.trim().isEmpty;
                        dobError = dob.trim().isEmpty;
                        phoneError = phoneController.text.trim().isEmpty;
                      });
                      if (firstNameError ||
                          lastNameError ||
                          genderError ||
                          dobError ||
                          phoneError) {
                        return;
                      }
                      setState(() {
                        firstName = firstNameController.text;
                        lastName = lastNameController.text;
                        phone = phoneController.text;
                        email = emailController.text;
                        gender = gender;
                        dob = selectedDate.toIso8601String().split('T')[0];
                        isEditing = false;
                      });
                      await _saveUserData();
                    },
                    child: const Text(
                      'Lưu thông tin',
                      style: TextStyle(
                        fontFamily: 'RobotoSlab',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF), // Trắng
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Color(0xFF000000), // Đen
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Color(0xFF000000),
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới Tính',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: gender.isEmpty ? null : gender,
            isExpanded: true,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'Nam', child: Text('Nam')),
              DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
              DropdownMenuItem(value: 'Khác', child: Text('Khác')),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  gender = newValue;
                });
              }
            },
            hint: const Text('Chọn giới tính'),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Color(0xFF000000),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngày Sinh',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFFA10F1A),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                  dob = picked.toIso8601String().split('T')[0];
                });
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dob.isEmpty ? 'Chọn ngày sinh' : dob,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Color(0xFF000000),
                  ),
                ),
                const Icon(Icons.calendar_today, color: Color(0xFFA10F1A)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
