import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class UpdateMyAccountScreen extends StatefulWidget {
  @override
  _UpdateMyAccountScreenState createState() => _UpdateMyAccountScreenState();
}

class _UpdateMyAccountScreenState extends State<UpdateMyAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender = "Nam";
  final List<String> genders = ["Nam", "Nữ", "Khác"];
  bool _isUpdated = false; // Kiểm tra có thay đổi thì mới bật nút Lưu
  File? _image; // Ảnh đại diện đã chọn
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  // Dữ liệu mặc định của tài khoản (giả định lấy từ API)
  final Map<String, dynamic> _userData = {
    'email': 'tt.1072002@gmail.com',
    'name': 'Thu Thảo',
    'phone': '+84 348 740 942',
    'gender': 'Nữ',
    'dob': '20/12/2024',
  };

  @override
  void initState() {
    super.initState();
    _nameController.text = _userData['name'];
    _phoneController.text = _userData['phone'];
    _dobController.text = _userData['dob'];
    _selectedGender = _userData['gender'];

    _nameController.addListener(_checkUpdated);
    _phoneController.addListener(_checkUpdated);
    _dobController.addListener(_checkUpdated);
  }

  void _checkUpdated() {
    setState(() {
      _isUpdated = _nameController.text != _userData['name'] ||
          _phoneController.text != _userData['phone'] ||
          _dobController.text != _userData['dob'] ||
          _selectedGender != _userData['gender'] ||
          _image != null;
    });
  }

  // Mở DatePicker để chọn ngày sinh
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            hintColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.blue),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _checkUpdated();
      });
    }
  }

  void _saveChanges() {
    if (!_isUpdated) return; // Nếu không có thay đổi thì không làm gì
    if (!_formKey.currentState!.validate()) return;
    // Kiểm tra các trường bắt buộc
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập họ tên!')),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập số điện thoại!')),
      );
      return;
    }

    if (_dobController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ngày sinh!')),
      );
      return;
    }

    // Xử lý số điện thoại: Nếu bắt đầu bằng "0", đổi thành "+84"
    String phone = _phoneController.text.trim();
    if (phone.startsWith("0")) {
      phone = "+84" + phone.substring(1);
      _phoneController.text = phone;
    }

    // In ra console (Thay bằng API thực tế)
    print(
        "Cập nhật thông tin: ${_nameController.text}, $phone, $_selectedGender, ${_dobController.text}, Ảnh: ${_image?.path}");

    // Gọi API cập nhật thông tin tại đây (nếu có)
    // Example:
    // ApiService.updateUserProfile(name: _nameController.text, phone: phone, gender: _selectedGender, dob: _dobController.text, image: _image?.path);

    setState(() {
      _isUpdated = false; // Reset trạng thái sau khi lưu
    });

    // Hiển thị thông báo thành công với hiệu ứng mượt mà
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cập nhật thành công!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating, // Hiển thị kiểu nổi
        backgroundColor: Colors.green,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cập nhật tài khoản",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ảnh đại diện + Chỉnh sửa ảnh
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image!) as ImageProvider
                      : AssetImage("assets/images/courses/courseExample.png"), 
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blue,
                    child:
                        Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _userData['name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _userData['email'],
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Form cập nhật
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(1, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  //họ tên
                  const Text.rich(
                    TextSpan(
                      text: "Họ tên ",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: "*",
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Họ tên không được để trống!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  //SDT
                  const Text.rich(
                    TextSpan(
                      text: "Số điện thoại ",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: "*",
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Số điện thoại không được để trống!";
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return "Số điện thoại chỉ được chứa số!";
                      }
                      if (value.length < 9 || value.length > 11) {
                        return "Số điện thoại không hợp lệ!";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.length > 1 &&
                          value.startsWith("0") &&
                          !value.startsWith("+84")) {
                        String newPhone = "+84" + value.substring(1);
                        _phoneController.value = TextEditingValue(
                          text: newPhone,
                          selection:
                              TextSelection.collapsed(offset: newPhone.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  //Giới tính
                  const Text(
                    "Giới tính",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: genders.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Align(
                          alignment: Alignment.centerLeft, // Căn trái nội dung
                          child: Text(
                            value,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text("Ngày sinh",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Vui lòng chọn ngày sinh!";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Nút Lưu
            SizedBox(
              width: 120, 
              child: ElevatedButton(
                onPressed: _isUpdated ? _saveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Lưu",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
