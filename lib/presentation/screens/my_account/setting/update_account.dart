import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UpdateAccountScreen extends StatefulWidget {
  const UpdateAccountScreen({Key? key}) : super(key: key);

  @override
  State<UpdateAccountScreen> createState() => _UpdateAccountScreenState();
}

class _UpdateAccountScreenState extends State<UpdateAccountScreen> {
  // Controllers cho các trường thông tin
  final TextEditingController _nameController =
      TextEditingController(text: 'Nguyễn Văn A');
  final TextEditingController _emailController =
      TextEditingController(text: 'nguyenvana@gmail.com');
  final TextEditingController _phoneController =
      TextEditingController(text: '0912345678');

  // Thông tin khác
  String _gender = 'Nam';
  DateTime _birthDate = DateTime(2000, 1, 1);
  File? _profileImage;
  bool _isLoading = false;

  // ImagePicker để chọn ảnh từ thư viện hoặc camera
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Format ngày tháng năm sinh
  String get _formattedBirthDate {
    return DateFormat('dd/MM/yyyy').format(_birthDate);
  }

  // Chọn ảnh từ thư viện
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Không thể chọn ảnh: $e');
    }
  }

  // Chụp ảnh từ camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Không thể chụp ảnh: $e');
    }
  }

  // Hiển thị dialog chọn ảnh
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thanh ngang ở trên cùng
            Container(
              height: 4,
              width: 50,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Chọn ảnh đại diện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.photo_library, color: Colors.white),
              ),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),

            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),

            if (_profileImage != null)
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                title: const Text('Xóa ảnh hiện tại'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = null;
                  });
                },
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Hiển thị dialog chọn ngày sinh
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  // Hiển thị thông báo lỗi
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Xử lý cập nhật thông tin
  Future<void> _updateProfile() async {
    // Kiểm tra thông tin hợp lệ
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập họ tên');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập số điện thoại');
      return;
    }

    // Bắt đầu loading
    setState(() {
      _isLoading = true;
    });

    // Giả lập gọi API cập nhật thông tin
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Hiển thị thông báo thành công
    if (mounted) {
      _showSuccessDialog();
    }
  }

  // Hiển thị dialog thành công
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            const Text('Thành công'),
          ],
        ),
        content: const Text(
            'Thông tin tài khoản của bạn đã được cập nhật thành công!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              Navigator.pop(context); // Quay lại màn hình trước
            },
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Cập nhật thông tin',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần ảnh đại diện
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : const AssetImage(
                                        'assets/images/avatar_placeholder.png')
                                    as ImageProvider,
                            child: _profileImage == null
                                ? const Icon(Icons.person,
                                    size: 60, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chạm để thay đổi ảnh đại diện',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Thông tin cá nhân
              const Text(
                'Thông tin cá nhân',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Họ tên
              _buildTextField(
                label: 'Họ và tên',
                controller: _nameController,
                prefixIcon: Icons.person,
                hintText: 'Nhập họ và tên',
              ),

              // Số điện thoại
              _buildTextField(
                label: 'Số điện thoại',
                controller: _phoneController,
                prefixIcon: Icons.phone,
                hintText: 'Nhập số điện thoại',
                keyboardType: TextInputType.phone,
              ),

              // Email (không cho chỉnh sửa)
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                prefixIcon: Icons.email,
                readOnly: true,
                hintText: 'Email của bạn',
              ),

              // Giới tính
              _buildDropdownField(
                label: 'Giới tính',
                prefixIcon: Icons.person_outline,
                value: _gender,
                items: const ['Nam', 'Nữ', 'Khác'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _gender = value;
                    });
                  }
                },
              ),

              // Ngày sinh
              _buildDatePickerField(
                label: 'Ngày sinh',
                value: _formattedBirthDate,
                prefixIcon: Icons.calendar_today,
                onTap: _selectBirthDate,
              ),

              const SizedBox(height: 32),

              // Nút cập nhật
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.blue.withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Cập nhật thông tin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Thông tin bổ sung
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị trường nhập thông tin
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    String? hintText,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              prefixIcon: Icon(prefixIcon, color: Colors.blue),
              filled: true,
              fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
            style: TextStyle(
              color: readOnly ? Colors.grey.shade700 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị trường dropdown
  Widget _buildDropdownField({
    required String label,
    required IconData prefixIcon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                borderRadius: BorderRadius.circular(12),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(prefixIcon, color: Colors.blue, size: 22),
                        const SizedBox(width: 12),
                        Text(item),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị trường chọn ngày
  Widget _buildDatePickerField({
    required String label,
    required String value,
    required IconData prefixIcon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(prefixIcon, color: Colors.blue),
                  const SizedBox(width: 16),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị thông tin bổ sung
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Mẹo cập nhật thông tin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem(
              'Cập nhật thông tin cá nhân giúp tài khoản của bạn an toàn hơn'),
          _buildTipItem(
              'Ảnh đại diện rõ nét giúp bạn được nhận diện dễ dàng hơn'),
          _buildTipItem(
              'Cập nhật số điện thoại chính xác để nhận được các thông báo quan trọng'),
          _buildTipItem(
              'Thông tin cá nhân của bạn được bảo mật và chỉ hiển thị khi cần thiết'),
        ],
      ),
    );
  }

  // Widget hiển thị mỗi mẹo
  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
