// import 'package:flutter/material.dart';
// import 'package:tms_app/core/di/service_locator.dart';
// import 'package:tms_app/presentation/screens/login/verify_email_screen.dart';
// import 'package:tms_app/presentation/screens/login/verify_sms_screen.dart';
// import '../../controller/forgot_password_controller.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   String _selectedMethod = "email"; // Mặc định chọn email
//   String? _userEmail;
//   String? _userPhone;
//   bool _loading = false;

//   late final ForgotPasswordController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = ForgotPasswordController(accountRepository: sl());
//     _fetchUserData(); // Lấy thông tin người dùng từ API
//   }

//   // Lấy thông tin người dùng từ API
//   Future<void> _fetchUserData() async {
//     setState(() {
//       _loading = true;
//     });

//     try {
//       final userData = await _controller.getUserData();
//       setState(() {
//         _userEmail = userData['email'];
//         _userPhone = userData['phone'];
//         _loading = false;
//       });
//     } catch (error) {
//       setState(() {
//         _loading = false;
//       });
//       _controller.showToast(error.toString(), true);
//     }
//   }

//   String _maskEmail(String email) {
//     List<String> parts = email.split('@');
//     if (parts.length != 2) return email;
//     String domain = parts[1];
//     String hiddenPart = '*' * (parts[0].length - 2);
//     return '${parts[0].substring(0, 2)}$hiddenPart@$domain';
//   }

//   String _maskPhone(String phone) {
//     if (phone.length < 10) return phone;
//     return '${phone.substring(0, 2)}${'*' * (phone.length - 4)}${phone.substring(phone.length - 2)}';
//   }

//   Future<void> _handleNext() async {
//     try {
//       setState(() {
//         _loading = true;
//       });

//       if (_selectedMethod == 'email' && _userEmail != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VerifyEmailScreen(
//               email: _userEmail!,
//               controller: _controller,
//             ),
//           ),
//         );
//       } else if (_selectedMethod == 'sms' && _userPhone != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VerifySMSScreen(
//               phone: _userPhone!,
//               controller: _controller,
//             ),
//           ),
//         );
//       }
//     } catch (error) {
//       _controller.showToast(error.toString(), true);
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 24),
//             const Text(
//               "Quên mật khẩu",
//               style: TextStyle(
//                 fontSize: 36,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Image.asset('assets/images/login/forgotPassword.png', height: 200),
//             const SizedBox(height: 16),
//             const Text(
//               'Vui lòng chọn phương thức xác minh!',
//               style: TextStyle(fontSize: 16, color: Colors.black54),
//             ),
//             const SizedBox(height: 48),
//             _loading
//                 ? const CircularProgressIndicator()
//                 : GestureDetector(
//                     onTap: () {
//                       setState(() => _selectedMethod = 'email');
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(18),
//                         border: Border.all(
//                           color: _selectedMethod == 'email'
//                               ? Colors.lightBlue
//                               : Colors.black54,
//                           width: 2,
//                         ),
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 8,
//                             spreadRadius: 2,
//                             offset: const Offset(2, 4),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.email, size: 36),
//                           const SizedBox(width: 0),
//                           Expanded(
//                             child: Column(
//                               children: [
//                                 const Text(
//                                   'via EMAIL',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Text(
//                                   _userEmail != null
//                                       ? _maskEmail(_userEmail!)
//                                       : " ",
//                                   style: const TextStyle(fontSize: 18),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//             const SizedBox(height: 24),
//             GestureDetector(
//               onTap: () {
//                 setState(() => _selectedMethod = 'sms');
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(18),
//                   border: Border.all(
//                     color: _selectedMethod == 'sms'
//                         ? Colors.lightBlue
//                         : Colors.black54,
//                     width: 2,
//                   ),
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 8,
//                       spreadRadius: 2,
//                       offset: const Offset(2, 4),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.sms, size: 24),
//                     const SizedBox(width: 12),
//                     const Text(
//                       'via SMS',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       _userPhone != null ? _maskPhone(_userPhone!) : " ",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 42),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 onPressed: _loading ? null : _handleNext,
//                 child: _loading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         'Tiếp',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
