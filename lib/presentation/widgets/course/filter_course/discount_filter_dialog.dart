// import 'package:flutter/material.dart';
// import 'package:tms_app/core/theme/app_styles.dart';

// class DiscountFilterDialog extends StatelessWidget {
//   final Map<String, bool> discountRanges;
//   final Function(String, bool) onUpdateRange;
//   final VoidCallback onResetRanges;

//   const DiscountFilterDialog({
//     Key? key,
//     required this.discountRanges,
//     required this.onUpdateRange,
//     required this.onResetRanges,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       backgroundColor: Colors.white,
//       clipBehavior: Clip.antiAlias,
//       elevation: 10,
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.95,
//         constraints: BoxConstraints(
//           maxWidth: 400,
//           maxHeight: 500,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header with gradient background
//             Container(
//               height: 70,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color(0xFF1976D2),
//                     Color(0xFF2196F3),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.local_offer_outlined,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       "Lọc theo giảm giá",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.close,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                       onPressed: () => Navigator.of(context).pop(),
//                       padding: EdgeInsets.all(8),
//                       constraints: BoxConstraints(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Content
//             Flexible(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                 ),
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       _buildDiscountRangeItem(
//                           context, '0-10%', discountRanges['0-10%'] ?? false),
//                       Divider(height: 1, indent: 70, endIndent: 20),
//                       _buildDiscountRangeItem(
//                           context, '10-30%', discountRanges['10-30%'] ?? false),
//                       Divider(height: 1, indent: 70, endIndent: 20),
//                       _buildDiscountRangeItem(
//                           context, '30-50%', discountRanges['30-50%'] ?? false),
//                       Divider(height: 1, indent: 70, endIndent: 20),
//                       _buildDiscountRangeItem(
//                           context, '50-70%', discountRanges['50-70%'] ?? false),
//                       Divider(height: 1, indent: 70, endIndent: 20),
//                       _buildDiscountRangeItem(
//                           context, '70%+', discountRanges['70%+'] ?? false),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // Footer with action buttons
//             Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: 20,
//                 vertical: 16,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: Offset(0, -5),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   OutlinedButton.icon(
//                     onPressed: () {
//                       onResetRanges();
//                       Navigator.of(context).pop();
//                     },
//                     icon: Icon(Icons.refresh, size: 18),
//                     label: Text("Đặt lại"),
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: Colors.grey.shade400),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFF1976D2),
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         padding: EdgeInsets.symmetric(vertical: 12),
//                       ),
//                       child: Text(
//                         "Áp dụng",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDiscountRangeItem(
//       BuildContext context, String range, bool value) {
//     String discountLabel = _getDiscountLabel(range);
//     Color progressColor = _getProgressColor(range);

//     return InkWell(
//       onTap: () => onUpdateRange(range, !value),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//         child: Row(
//           children: [
//             SizedBox(
//               width: 30,
//               height: 30,
//               child: Checkbox(
//                 value: value,
//                 onChanged: (newValue) {
//                   if (newValue != null) {
//                     onUpdateRange(range, newValue);
//                   }
//                 },
//                 activeColor: Color(0xFF1976D2),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//             ),
//             SizedBox(width: 20),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   range,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: value ? FontWeight.bold : FontWeight.w500,
//                     color: value ? Color(0xFF1976D2) : Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 6),
//                 Text(
//                   discountLabel,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//             Spacer(),
//             Container(
//               width: 60,
//               height: 8,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: FractionallySizedBox(
//                 alignment: Alignment.centerLeft,
//                 widthFactor: _getProgressWidth(range),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: progressColor,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _getDiscountLabel(String range) {
//     switch (range) {
//       case '0-10%':
//         return 'Khuyến mãi nhỏ';
//       case '10-30%':
//         return 'Khuyến mãi vừa';
//       case '30-50%':
//         return 'Khuyến mãi lớn';
//       case '50-70%':
//         return 'Khuyến mãi đặc biệt';
//       case '70%+':
//         return 'Siêu khuyến mãi';
//       default:
//         return '';
//     }
//   }

//   Color _getProgressColor(String range) {
//     switch (range) {
//       case '0-10%':
//         return Colors.lightBlue;
//       case '10-30%':
//         return Colors.blue;
//       case '30-50%':
//         return Colors.indigo;
//       case '50-70%':
//         return Colors.deepPurple;
//       case '70%+':
//         return Colors.purple;
//       default:
//         return Colors.blue;
//     }
//   }

//   double _getProgressWidth(String range) {
//     switch (range) {
//       case '0-10%':
//         return 0.1;
//       case '10-30%':
//         return 0.3;
//       case '30-50%':
//         return 0.5;
//       case '50-70%':
//         return 0.7;
//       case '70%+':
//         return 0.9;
//       default:
//         return 0.3;
//     }
//   }
// }
