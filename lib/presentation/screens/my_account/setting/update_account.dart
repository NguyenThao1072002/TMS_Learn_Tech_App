import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/account/user_update_model.dart';
import 'package:tms_app/domain/usecases/update_account_usecase.dart';
import 'package:tms_app/presentation/controller/my_account/setting/update_account_controller.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';

class UpdateAccountScreen extends StatefulWidget {
  const UpdateAccountScreen({Key? key}) : super(key: key);

  @override
  State<UpdateAccountScreen> createState() => _UpdateAccountScreenState();
}

class _UpdateAccountScreenState extends State<UpdateAccountScreen> {
  // Khởi tạo controller thông qua Dependency Injection
  late final UpdateAccountController _controller;

  // Controllers cho các trường thông tin
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController =
      TextEditingController(text: 'Nam');
  final TextEditingController _birthdayController = TextEditingController();

  // Theme colors
  late Color _backgroundColor;
  late Color _cardColor;
  late Color _textColor;
  late Color _textSecondaryColor;
  late Color _inputFillColor;
  late Color _borderColor;
  late Color _shadowColor;

  // Biến để lưu trạng thái
  File? _profileImage;
  String? _currentImagePath;
  bool _hasUnsavedChanges = false;
  DateTime _selectedDate = DateTime(2000, 1, 1);

  // ImagePicker để chọn ảnh từ thư viện hoặc camera
  final ImagePicker _picker = ImagePicker();

  void _initializeColors(bool isDarkMode) {
    if (isDarkMode) {
      _backgroundColor = const Color(0xFF121212);
      _cardColor = const Color(0xFF1E1E1E);
      _textColor = Colors.white;
      _textSecondaryColor = Colors.grey.shade300;
      _inputFillColor = const Color(0xFF2A2D3E);
      _borderColor = Colors.grey.shade700;
      _shadowColor = Colors.black.withOpacity(0.3);
    } else {
      _backgroundColor = Colors.white;
      _cardColor = Colors.white;
      _textColor = Colors.black87;
      _textSecondaryColor = Colors.grey.shade700;
      _inputFillColor = Colors.grey.withOpacity(0.05);
      _borderColor = Colors.grey.shade300;
      _shadowColor = Colors.black.withOpacity(0.1);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = UpdateAccountController(
      updateAccountUseCase: GetIt.instance<UpdateAccountUseCase>(),
    );

    // Lắng nghe sự thay đổi của userProfile
    _controller.userProfile.listen((profile) {
      if (profile != null) {
        setState(() {
          _nameController.text = profile.fullname ?? '';
          _emailController.text = profile.email ?? '';
          _phoneController.text = profile.phone ?? '';
          _genderController.text = profile.gender ?? 'Nam';

          // Chuyển đổi birthday string từ API sang DateTime
          if (profile.birthday != null && profile.birthday!.isNotEmpty) {
            _selectedDate =
                DateTime.tryParse(profile.birthday!) ?? DateTime(2000, 1, 1);
            _birthdayController.text =
                DateFormat('dd/MM/yyyy').format(_selectedDate);
          }

          _currentImagePath = profile.image;
        });
      }
    });

    // Lấy thông tin người dùng khi màn hình được mở
    _loadUserData();
  }

  // Phương thức để tải dữ liệu người dùng
  Future<void> _loadUserData() async {
    await _controller.fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Format ngày tháng năm sinh
  String get _formattedBirthDate {
    return _birthdayController.text.isNotEmpty
        ? _birthdayController.text
        : DateFormat('dd/MM/yyyy').format(_selectedDate);
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
          _hasUnsavedChanges = true;
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
          _hasUnsavedChanges = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Không thể chụp ảnh: $e');
    }
  }

  // Hiển thị dialog chọn ảnh
  void _showImagePickerOptions(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2A2D3E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.3) 
                  : Colors.black.withOpacity(0.1),
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
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Chọn ảnh đại diện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),

            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.photo_library, color: Colors.white),
              ),
              title: Text(
                'Chọn từ thư viện', 
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              ),
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
              title: Text(
                'Chụp ảnh mới',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),

            if (_profileImage != null || _currentImagePath != null)
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                title: Text(
                  'Xóa ảnh hiện tại',
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = null;
                    _currentImagePath = null;
                    _hasUnsavedChanges = true;
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
      initialDate: _selectedDate,
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

    if (picked != null && picked != _selectedDate) {
      // Tính toán thời điểm 5 năm trước
      final DateTime fiveYearsAgo =
          DateTime.now().subtract(const Duration(days: 365 * 5 + 1));

      // Kiểm tra nếu ngày đã chọn lớn hơn fiveYearsAgo (nghĩa là nhỏ hơn 5 tuổi)
      if (picked.isAfter(fiveYearsAgo)) {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tuổi phải lớn hơn 5 tuổi'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        // Không cập nhật ngày sinh đã chọn
        return;
      }

      // Nếu tuổi hợp lệ, cập nhật ngày sinh
      setState(() {
        _selectedDate = picked;
        _birthdayController.text =
            DateFormat('dd/MM/yyyy').format(_selectedDate);
        _hasUnsavedChanges = true;
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

    // Kiểm tra định dạng số điện thoại
    bool isValidPhone = RegExp(
      r'^(?:\+84|84|0)[3|5|7|8|9][0-9]{8}$',
    ).hasMatch(_phoneController.text.trim());

    if (_phoneController.text.trim().isNotEmpty && !isValidPhone) {
      _showErrorSnackBar('Số điện thoại không hợp lệ');
      return;
    }

    // Tạo object data để gửi lên API theo đúng định dạng form-data
    final Map<String, dynamic> data = {
      'fullname': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'gender': _genderController.text,
      'birthday': _selectedDate
          .toIso8601String()
          .split('.')[0], // Định dạng 2002-07-10T00:00:00
    };

    // Nếu có ảnh mới được chọn
    if (_profileImage != null) {
      // Thêm ảnh dưới dạng File vào data để controller có thể xử lý gửi form-data
      data['image'] = _profileImage;
    }

    print('Dữ liệu gửi lên server: $data');

    // Gọi API cập nhật
    final success = await _controller.updateAccount(data);

    if (!success) {
      _showErrorSnackBar(_controller.errorMessage.value);
      return;
    }

    // Cập nhật thành công, hiển thị thông báo
    if (mounted) {
      _showSuccessDialog();
    }

    // Đặt lại trạng thái chưa lưu
    setState(() {
      _hasUnsavedChanges = false;
    });
  }

  // Hiển thị dialog thành công
  void _showSuccessDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2A2D3E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.black.withOpacity(0.3) 
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon thành công
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 70,
                  ),
                ),
                const SizedBox(height: 20),

                // Tiêu đề
                Text(
                  'Cập nhật thành công! 🎉',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                // Nội dung
                Text(
                  'Thông tin tài khoản của bạn đã được cập nhật thành công.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // Nút đóng
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Đóng dialog
                      Navigator.pop(context); // Quay lại màn hình trước
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Phương thức để hiện cảnh báo khi có thay đổi chưa lưu
  void _showUnsavedChangesDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2D3E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Thay đổi chưa được lưu',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Bạn có thay đổi chưa được lưu. Bạn muốn thoát mà không lưu không?',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tiếp tục chỉnh sửa',
              style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
              Navigator.pop(context); // Quay lại màn hình trước
            },
            child: const Text(
              'Thoát không lưu',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detect dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _initializeColors(isDarkMode);
    
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: Text(
          'Cập nhật thông tin',
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _textColor),
          onPressed: () {
            // Kiểm tra nếu có thay đổi chưa lưu trước khi thoát
            if (_hasUnsavedChanges) {
              _showUnsavedChangesDialog();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  // Phương thức hiển thị body của màn hình
  Widget _buildBody() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Obx(
      () {
        // Hiển thị loading khi đang tải dữ liệu
        if (_controller.isLoading.value &&
            _controller.userProfile.value == null) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        // Hiển thị thông báo lỗi nếu có
        if (_controller.errorMessage.value.isNotEmpty &&
            _controller.userProfile.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Đã xảy ra lỗi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _textSecondaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadUserData,
                  child: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        // Hiển thị form cập nhật khi đã có dữ liệu
        return GestureDetector(
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
                        onTap: () => _showImagePickerOptions(isDarkMode),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                              backgroundImage: _getProfileImage(),
                              child: _profileImage == null &&
                                      _currentImagePath == null
                                  ? Icon(Icons.person,
                                      size: 60, color: isDarkMode ? Colors.grey.shade600 : Colors.grey)
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
                                      Border.all(color: _backgroundColor, width: 2),
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
                      Text(
                        'Chạm để thay đổi ảnh đại diện',
                        style: TextStyle(
                          fontSize: 14,
                          color: _textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Thông tin cá nhân
                Text(
                  'Thông tin cá nhân',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Họ tên
                _buildTextField(
                  label: 'Họ và tên',
                  controller: _nameController,
                  prefixIcon: Icons.person,
                  hintText: 'Nhập họ và tên',
                  onChanged: (_) => _hasUnsavedChanges = true,
                  isDarkMode: isDarkMode,
                ),

                // Số điện thoại
                _buildTextField(
                  label: 'Số điện thoại',
                  controller: _phoneController,
                  prefixIcon: Icons.phone,
                  hintText: 'Nhập số điện thoại',
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    _hasUnsavedChanges = true;

                    // Kiểm tra số điện thoại hợp lệ
                    bool isValidPhone = RegExp(
                      r'^(?:\+84|84|0)[3|5|7|8|9][0-9]{8}$',
                    ).hasMatch(value.trim());

                    // Hiển thị lỗi nếu số điện thoại không hợp lệ và có giá trị
                    if (value.trim().isNotEmpty && !isValidPhone) {
                      // Hiển thị lỗi - ở đây bạn có thể dùng ScaffoldMessenger nếu muốn
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Số điện thoại không hợp lệ'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  isDarkMode: isDarkMode,
                ),
                // Email (không cho chỉnh sửa)
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  readOnly: true,
                  hintText: 'Email của bạn',
                  isDarkMode: isDarkMode,
                ),

                // Giới tính
                _buildDropdownField(
                  label: 'Giới tính',
                  prefixIcon: Icons.person_outline,
                  controller: _genderController,
                  items: const ['Nam', 'Nữ', 'Khác'],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _hasUnsavedChanges = true;
                      });
                    }
                  },
                  isDarkMode: isDarkMode,
                ),

                // Ngày sinh
                _buildDatePickerField(
                  label: 'Ngày sinh',
                  controller: _birthdayController,
                  prefixIcon: Icons.calendar_today,
                  onTap: _selectBirthDate,
                  isDarkMode: isDarkMode,
                ),

                const SizedBox(height: 32),

                // Nút cập nhật
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _controller.isLoading.value ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.blue.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _controller.isLoading.value
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
                _buildInfoCard(isDarkMode),
              ],
            ),
          ),
        );
      },
    );
  }

  // Phương thức để lấy ảnh đại diện hiện tại
  ImageProvider? _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (_currentImagePath != null && _currentImagePath!.isNotEmpty) {
      // Kiểm tra nếu là đường dẫn đầy đủ có http thì lấy từ network
      if (_currentImagePath!.startsWith('http')) {
        return NetworkImage(_currentImagePath!);
      }
      // Nếu là đường dẫn local
      return AssetImage(_currentImagePath!);
    }
    return const AssetImage('assets/images/avatar_placeholder.png');
  }

  // Widget hiển thị trường nhập thông tin
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    String? hintText,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    bool isDarkMode = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              prefixIcon: Icon(
                prefixIcon, 
                color: isDarkMode ? Colors.blue.withOpacity(0.7) : Colors.blue,
              ),
              filled: true,
              fillColor: readOnly 
                  ? (isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100)
                  : (isDarkMode ? const Color(0xFF2A2D3E) : Colors.grey.shade50),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.blue, 
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
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
    required TextEditingController controller,
    required List<String> items,
    required Function(String?) onChanged,
    bool isDarkMode = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2A2D3E) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.text,
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down, 
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                borderRadius: BorderRadius.circular(12),
                dropdownColor: isDarkMode ? const Color(0xFF2A2D3E) : Colors.white,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(
                          prefixIcon, 
                          color: isDarkMode ? Colors.blue.withOpacity(0.7) : Colors.blue, 
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.text = value;
                    onChanged(value);
                  }
                },
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
    required TextEditingController controller,
    required IconData prefixIcon,
    required VoidCallback onTap,
    bool isDarkMode = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2A2D3E) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    prefixIcon, 
                    color: isDarkMode ? Colors.blue.withOpacity(0.7) : Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    controller.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_drop_down, 
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị thông tin bổ sung
  Widget _buildInfoCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.blue.withOpacity(0.1) 
            : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? Colors.blue.withOpacity(0.2) 
              : Colors.blue.withOpacity(0.1),
        ),
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
              'Cập nhật thông tin cá nhân giúp tài khoản của bạn an toàn hơn',
              isDarkMode),
          _buildTipItem(
              'Ảnh đại diện rõ nét giúp bạn được nhận diện dễ dàng hơn',
              isDarkMode),
          _buildTipItem(
              'Cập nhật số điện thoại chính xác để nhận được các thông báo quan trọng',
              isDarkMode),
          _buildTipItem(
              'Thông tin cá nhân của bạn được bảo mật và chỉ hiển thị khi cần thiết',
              isDarkMode),
        ],
      ),
    );
  }

  // Widget hiển thị mỗi mẹo
  Widget _buildTipItem(String tip, bool isDarkMode) {
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
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
