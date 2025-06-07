// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tms_app/presentation/controller/theme_controller.dart';
// import 'package:tms_app/presentation/controller/language_controller.dart';
// import 'package:tms_app/presentation/screens/my_account/setting/theme_settings.dart';
// import 'package:tms_app/presentation/screens/my_account/setting/language_settings.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final themeController = Provider.of<ThemeController>(context);
//     final languageController = Provider.of<LanguageController>(context);
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Cài đặt'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Display settings
//               const Text(
//                 'Hiển thị',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 8),
              
//               // Theme switching
//               Card(
//                 margin: const EdgeInsets.only(bottom: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             themeController.themeMode == ThemeMode.dark
//                                 ? Icons.dark_mode
//                                 : (themeController.themeMode == ThemeMode.light
//                                     ? Icons.light_mode
//                                     : Icons.brightness_auto),
//                             color: Theme.of(context).primaryColor,
//                           ),
//                           const SizedBox(width: 16),
//                           const Text(
//                             'Giao diện',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const Spacer(),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const ThemeSettingsScreen(),
//                                 ),
//                               );
//                             },
//                             child: const Text('Tùy chỉnh thêm'),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8.0,
//                         children: [
//                           _buildThemeChip(
//                             context,
//                             title: 'Sáng',
//                             icon: Icons.light_mode,
//                             isSelected: themeController.themeMode == ThemeMode.light,
//                             onTap: () => themeController.setThemeMode(ThemeMode.light),
//                           ),
//                           _buildThemeChip(
//                             context,
//                             title: 'Tối',
//                             icon: Icons.dark_mode,
//                             isSelected: themeController.themeMode == ThemeMode.dark,
//                             onTap: () => themeController.setThemeMode(ThemeMode.dark),
//                           ),
//                           _buildThemeChip(
//                             context,
//                             title: 'Hệ thống',
//                             icon: Icons.brightness_auto,
//                             isSelected: themeController.themeMode == ThemeMode.system,
//                             onTap: () => themeController.setThemeMode(ThemeMode.system),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               // Language switching
//               Card(
//                 margin: const EdgeInsets.only(bottom: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.language,
//                             color: Theme.of(context).primaryColor,
//                           ),
//                           const SizedBox(width: 16),
//                           const Text(
//                             'Ngôn ngữ',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const Spacer(),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const LanguageSettingsScreen(),
//                                 ),
//                               );
//                             },
//                             child: const Text('Tùy chỉnh thêm'),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8.0,
//                         children: languageController.availableLanguages.map((language) {
//                           final isSelected = languageController.currentLocale.languageCode == language['code'];
//                           return _buildLanguageChip(
//                             context,
//                             flag: language['flag'],
//                             title: language['name'],
//                             isSelected: isSelected,
//                             onTap: () => languageController.setLanguage(language['code']),
//                           );
//                         }).toList(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               const SizedBox(height: 24),
              
//               // App settings
//               const Text(
//                 'Ứng dụng',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               _buildSettingsCard(
//                 context,
//                 title: 'Thông báo',
//                 subtitle: 'Quản lý thông báo',
//                 icon: Icons.notifications_outlined,
//                 onTap: () {
//                   // TODO: Navigate to notifications settings
//                 },
//               ),
//               _buildSettingsCard(
//                 context,
//                 title: 'Tải xuống',
//                 subtitle: 'Quản lý tải xuống',
//                 icon: Icons.download_outlined,
//                 onTap: () {
//                   // TODO: Navigate to download settings
//                 },
//               ),
              
//               const SizedBox(height: 24),
              
//               // About and support
//               const Text(
//                 'Thông tin & Hỗ trợ',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               _buildSettingsCard(
//                 context,
//                 title: 'Về chúng tôi',
//                 subtitle: 'Thông tin ứng dụng',
//                 icon: Icons.info_outline,
//                 onTap: () {
//                   // TODO: Navigate to about screen
//                 },
//               ),
//               _buildSettingsCard(
//                 context,
//                 title: 'Trợ giúp & Hỗ trợ',
//                 subtitle: 'Liên hệ hỗ trợ',
//                 icon: Icons.help_outline,
//                 onTap: () {
//                   // TODO: Navigate to help and support
//                 },
//               ),
//               _buildSettingsCard(
//                 context,
//                 title: 'Điều khoản sử dụng',
//                 subtitle: 'Chính sách và điều khoản',
//                 icon: Icons.description_outlined,
//                 onTap: () {
//                   // TODO: Navigate to terms and conditions
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildThemeChip(
//     BuildContext context, {
//     required String title,
//     required IconData icon,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isSelected 
//                 ? Theme.of(context).primaryColor 
//                 : Theme.of(context).dividerColor,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 16,
//               color: isSelected 
//                   ? Colors.white 
//                   : Theme.of(context).textTheme.bodyLarge?.color,
//             ),
//             const SizedBox(width: 4),
//             Text(
//               title,
//               style: TextStyle(
//                 color: isSelected 
//                     ? Colors.white 
//                     : Theme.of(context).textTheme.bodyLarge?.color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildLanguageChip(
//     BuildContext context, {
//     required String flag,
//     required String title,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isSelected 
//                 ? Theme.of(context).primaryColor 
//                 : Theme.of(context).dividerColor,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(flag, style: const TextStyle(fontSize: 16)),
//             const SizedBox(width: 4),
//             Text(
//               title,
//               style: TextStyle(
//                 color: isSelected 
//                     ? Colors.white 
//                     : Theme.of(context).textTheme.bodyLarge?.color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildSettingsCard(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: Theme.of(context).primaryColor,
//         ),
//         title: Text(title),
//         subtitle: Text(subtitle),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//         onTap: onTap,
//       ),
//     );
//   }
// } 