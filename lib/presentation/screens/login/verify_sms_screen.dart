// import 'package:flutter/material.dart';
// import 'package:tms_app/presentation/controller/forgot_password_controller.dart'; // Import controller thích hợp
// import 'package:tms_app/core/di/service_locator.dart'; // Đảm bảo DI (Dependency Injection) cho ForgotPasswordController
// import 'package:tms_app/presentation/widgets/component/bottom_wave_clipper.dart';
// import 'package:tms_app/presentation/screens/login/verify_otp_screen.dart'; // Thêm import cho VerifyOtpScreen

// class VerifySMSScreen extends StatefulWidget {
//   final String phone;
//   final ForgotPasswordController controller;

//   const VerifySMSScreen({
//     super.key,
//     required this.phone,
//     required this.controller,
//   });

//   @override
//   _VerifySMSScreenState createState() => _VerifySMSScreenState();
// }

// class _VerifySMSScreenState extends State<VerifySMSScreen> {
//   final TextEditingController _smsController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   bool isValidPhoneNumber(String phone) {
//     final RegExp phoneRegex = RegExp(r'^(?:\+84|0)([35789])[0-9]{8}$');
//     return phoneRegex.hasMatch(phone);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Quên mật khẩu",
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Stack(
//         // Bọc stack để làm hiệu ứng cong nền
//         children: [
//           // Hiệu ứng
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: ClipPath(
//               clipper: BottomWaveClipper(),
//               child: Container(
//                 height: 120,
//                 color: Colors.blue.withOpacity(0.1),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 100),
//                   const Text('Tìm tài khoản',
//                       style: TextStyle(
//                           fontSize: 36,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black)),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'Chúng tôi sẽ gửi mã OTP xác thự qua SĐT của bạn.',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 60),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Nhập số điện thoại của bạn!',
//                           style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.black,
//                               fontWeight: FontWeight.w500)),
//                       const SizedBox(height: 24),
//                       TextFormField(
//                         controller: _smsController,
//                         decoration: InputDecoration(
//                           hintText: 'VD: 0348740942',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return "Số điện thoại không được để trống!";
//                           }
//                           if (!isValidPhoneNumber(value)) {
//                             return "Số điện thoại không hợp lệ! Vui lòng nhập đúng định dạng.";
//                           }
//                           return null;
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 60),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       onPressed: () async {
//                         if (_formKey.currentState!.validate()) {
//                           final success =
//                               await widget.controller.sendOtpToEmail(
//                             _smsController.text.trim(),
//                           );
//                           if (success) {
//                             // Chuyển sang màn hình xác thực OTP
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => VerifyOtpScreen(
//                                   email: _smsController.text.trim(),
//                                   controller: widget.controller,
//                                   isPhoneNumber: true,
//                                 ),
//                               ),
//                             );
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content:
//                                     Text(widget.controller.errorMessage.value),
//                               ),
//                             );
//                           }
//                         }
//                       },
//                       child: const Text('Gửi mã',
//                           style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
