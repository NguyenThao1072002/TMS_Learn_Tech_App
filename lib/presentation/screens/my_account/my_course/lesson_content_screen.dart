// import 'package:flutter/material.dart';

// class LessonContentScreen extends StatefulWidget {
//   final String lessonTitle;
//   final String courseTitle;
//   final String videoUrl;
//   final List<MaterialItem> materials;
//   final String summary;
//   final bool hasTest;

//   const LessonContentScreen({
//     Key? key,
//     required this.lessonTitle,
//     required this.courseTitle,
//     required this.videoUrl,
//     required this.materials,
//     required this.summary,
//     this.hasTest = true,
//   }) : super(key: key);

//   @override
//   State<LessonContentScreen> createState() => _LessonContentScreenState();
// }

// class _LessonContentScreenState extends State<LessonContentScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _isVideoPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // Compact header with course info
//           _buildCompactHeader(),

//           // Tab bar for navigation between content types
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: TabBar(
//               controller: _tabController,
//               labelColor: Colors.orange,
//               unselectedLabelColor: Colors.grey[600],
//               indicatorColor: Colors.orange,
//               tabs: const [
//                 Tab(icon: Icon(Icons.play_circle_filled), text: 'Video'),
//                 Tab(icon: Icon(Icons.menu_book), text: 'Tài liệu'),
//                 Tab(icon: Icon(Icons.summarize), text: 'Tóm tắt'),
//               ],
//             ),
//           ),

//           // Tab content
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildVideoContent(),
//                 _buildMaterialsContent(),
//                 _buildSummaryContent(),
//               ],
//             ),
//           ),
//         ],
//       ),
//       // Floating action button for test
//       floatingActionButton: widget.hasTest ? _buildTestFAB() : null,
//     );
//   }

//   Widget _buildCompactHeader() {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top,
//         left: 16,
//         right: 16,
//         bottom: 16,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.of(context).pop(),
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   widget.lessonTitle,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   widget.courseTitle,
//                   style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.bookmark_border),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Đã lưu vào danh sách đánh dấu'),
//                   behavior: SnackBarBehavior.floating,
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.more_vert),
//             onPressed: () {
//               _showOptionsMenu(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVideoContent() {
//     return Stack(
//       children: [
//         SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Video player (mock)
//               AspectRatio(
//                 aspectRatio: 16 / 9,
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _isVideoPlaying = !_isVideoPlaying;
//                     });
//                   },
//                   child: Container(
//                     color: Colors.black,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         // Video placeholder (replace with actual video player in real app)
//                         Image.network(
//                           'https://img.youtube.com/vi/${widget.videoUrl}/hqdefault.jpg',
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               color: Colors.grey[800],
//                               child: const Center(
//                                 child: Icon(
//                                   Icons.video_library,
//                                   size: 64,
//                                   color: Colors.white54,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),

//                         // Play button overlay
//                         if (!_isVideoPlaying)
//                           Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.5),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.play_arrow,
//                               size: 50,
//                               color: Colors.white,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               // Student comments section
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Bình luận của học viên',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Comment input field
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: TextField(
//                         maxLines: 3,
//                         decoration: InputDecoration(
//                           hintText: 'Viết bình luận của bạn...',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           contentPadding: const EdgeInsets.all(16),
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.send, color: Colors.orange),
//                             onPressed: () {
//                               // Send comment logic
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Đã gửi bình luận'),
//                                   behavior: SnackBarBehavior.floating,
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     // Sample comments
//                     _buildCommentItem(
//                       'Nguyễn Văn A',
//                       'Bài học rất hữu ích, giảng viên giải thích rất rõ ràng!',
//                       '2 giờ trước',
//                       'https://randomuser.me/api/portraits/men/32.jpg',
//                     ),

//                     _buildCommentItem(
//                       'Trần Thị B',
//                       'Tôi vẫn chưa hiểu phần về sử dụng StatefulWidget, liệu giảng viên có thể giải thích thêm được không?',
//                       '4 giờ trước',
//                       'https://randomuser.me/api/portraits/women/44.jpg',
//                     ),

//                     _buildCommentItem(
//                       'Lê Văn C',
//                       'Đã học xong bài này, rất hay và đầy đủ thông tin!',
//                       '1 ngày trước',
//                       'https://randomuser.me/api/portraits/men/86.jpg',
//                     ),
//                   ],
//                 ),
//               ),

//               // Add space at bottom for the fixed button
//               const SizedBox(height: 70),
//             ],
//           ),
//         ),

//         // Fixed "Complete" button at bottom
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.3),
//                   spreadRadius: 1,
//                   blurRadius: 5,
//                   offset: const Offset(0, -3),
//                 ),
//               ],
//             ),
//             child: ElevatedButton(
//               onPressed: () {
//                 // Mark lesson as complete
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Đã hoàn thành bài học'),
//                     behavior: SnackBarBehavior.floating,
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text(
//                 'Hoàn thành bài học',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCommentItem(
//       String name, String comment, String time, String avatarUrl) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             radius: 20,
//             backgroundImage: NetworkImage(avatarUrl),
//             onBackgroundImageError: (e, s) => const Icon(Icons.person),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                     Text(
//                       time,
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   comment,
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     TextButton.icon(
//                       onPressed: () {},
//                       icon: const Icon(Icons.thumb_up_outlined, size: 16),
//                       label: const Text('Thích'),
//                       style: TextButton.styleFrom(
//                         foregroundColor: Colors.grey[700],
//                         padding: EdgeInsets.zero,
//                         minimumSize: const Size(50, 30),
//                         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       ),
//                     ),
//                     TextButton.icon(
//                       onPressed: () {},
//                       icon: const Icon(Icons.reply_outlined, size: 16),
//                       label: const Text('Trả lời'),
//                       style: TextButton.styleFrom(
//                         foregroundColor: Colors.grey[700],
//                         padding: EdgeInsets.zero,
//                         minimumSize: const Size(50, 30),
//                         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMaterialsContent() {
//     return widget.materials.isEmpty
//         ? Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Chưa có tài liệu nào',
//                   style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           )
//         : ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: widget.materials.length,
//             itemBuilder: (context, index) {
//               final material = widget.materials[index];
//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.all(12),
//                   leading: Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       color: _getMaterialColor(material.type).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       _getMaterialIcon(material.type),
//                       color: _getMaterialColor(material.type),
//                     ),
//                   ),
//                   title: Text(
//                     material.title,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   subtitle: Text(
//                     material.description,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.download),
//                     onPressed: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Đang tải xuống ${material.title}'),
//                           behavior: SnackBarBehavior.floating,
//                         ),
//                       );
//                     },
//                   ),
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Đang mở ${material.title}'),
//                         behavior: SnackBarBehavior.floating,
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//   }

//   Widget _buildSummaryContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Tóm tắt bài học',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             widget.summary,
//             style: const TextStyle(fontSize: 16, height: 1.6),
//           ),
//           const SizedBox(height: 24),

//           // Key points
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.orange.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.orange.withOpacity(0.3)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Row(
//                   children: [
//                     Icon(Icons.lightbulb, color: Colors.orange),
//                     SizedBox(width: 8),
//                     Text(
//                       'Điểm chính',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.orange,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 // Sample key points
//                 ..._buildKeyPoints(),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Related resources
//           const Text(
//             'Tài nguyên liên quan',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           _buildRelatedResources(),
//         ],
//       ),
//     );
//   }

//   List<Widget> _buildKeyPoints() {
//     final keyPoints = [
//       'Hiểu về cấu trúc cơ bản của ứng dụng Flutter',
//       'Sử dụng thành thạo StatefulWidget và StatelessWidget',
//       'Triển khai quản lý trạng thái hiệu quả',
//       'Áp dụng nguyên tắc thiết kế UI cho ứng dụng di động',
//     ];

//     return keyPoints.map((point) {
//       return Padding(
//         padding: const EdgeInsets.only(bottom: 8),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Icon(Icons.check_circle, size: 16, color: Colors.orange),
//             const SizedBox(width: 8),
//             Expanded(child: Text(point, style: const TextStyle(fontSize: 16))),
//           ],
//         ),
//       );
//     }).toList();
//   }

//   Widget _buildRelatedResources() {
//     final resources = [
//       {
//         'title': 'Tài liệu Flutter chính thức',
//         'url': 'https://flutter.dev/docs',
//         'icon': Icons.open_in_new,
//       },
//       {
//         'title': 'Flutter Widget Catalog',
//         'url': 'https://flutter.dev/docs/development/ui/widgets',
//         'icon': Icons.widgets,
//       },
//       {
//         'title': 'State Management in Flutter',
//         'url':
//             'https://flutter.dev/docs/development/data-and-backend/state-mgmt',
//         'icon': Icons.article,
//       },
//     ];

//     return Column(
//       children: resources.map((resource) {
//         return ListTile(
//           contentPadding: EdgeInsets.zero,
//           leading: CircleAvatar(
//             backgroundColor: Colors.blue.withOpacity(0.1),
//             child: Icon(resource['icon'] as IconData, color: Colors.blue),
//           ),
//           title: Text(resource['title'] as String),
//           subtitle: Text(resource['url'] as String),
//           onTap: () {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Đang mở ${resource['title']}'),
//                 behavior: SnackBarBehavior.floating,
//               ),
//             );
//           },
//         );
//       }).toList(),
//     );
//   }

//   void _showOptionsMenu(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.symmetric(vertical: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.picture_in_picture),
//                 title: const Text('Chế độ thu nhỏ'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Đã chuyển sang chế độ thu nhỏ'),
//                       behavior: SnackBarBehavior.floating,
//                     ),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.download),
//                 title: const Text('Tải xuống bài học'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Đang tải xuống bài học'),
//                       behavior: SnackBarBehavior.floating,
//                     ),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.share),
//                 title: const Text('Chia sẻ'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Đang mở tùy chọn chia sẻ'),
//                       behavior: SnackBarBehavior.floating,
//                     ),
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.report_problem, color: Colors.orange),
//                 title: const Text('Báo cáo vấn đề'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Đang mở form báo cáo'),
//                       behavior: SnackBarBehavior.floating,
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTestFAB() {
//     return FloatingActionButton.extended(
//       onPressed: () {
//         _showTestConfirmation();
//       },
//       backgroundColor: Colors.orange,
//       icon: const Icon(Icons.quiz),
//       label: const Text('Kiểm tra bài học'),
//     );
//   }

//   void _showTestConfirmation() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Bắt đầu kiểm tra?'),
//         content: const Text(
//           'Bạn có muốn làm bài kiểm tra kiến thức bài học này không? Bạn cần đạt ít nhất 70% để đạt.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Để sau'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               // Here you would navigate to the test screen
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Đang mở bài kiểm tra'),
//                   behavior: SnackBarBehavior.floating,
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//             child: const Text('Bắt đầu ngay'),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getMaterialColor(MaterialType type) {
//     switch (type) {
//       case MaterialType.pdf:
//         return Colors.red;
//       case MaterialType.document:
//         return Colors.blue;
//       case MaterialType.presentation:
//         return Colors.orange;
//       case MaterialType.spreadsheet:
//         return Colors.green;
//       case MaterialType.image:
//         return Colors.purple;
//       case MaterialType.code:
//         return Colors.teal;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getMaterialIcon(MaterialType type) {
//     switch (type) {
//       case MaterialType.pdf:
//         return Icons.picture_as_pdf;
//       case MaterialType.document:
//         return Icons.description;
//       case MaterialType.presentation:
//         return Icons.slideshow;
//       case MaterialType.spreadsheet:
//         return Icons.table_chart;
//       case MaterialType.image:
//         return Icons.image;
//       case MaterialType.code:
//         return Icons.code;
//       default:
//         return Icons.insert_drive_file;
//     }
//   }
// }

// enum MaterialType {
//   pdf,
//   document,
//   presentation,
//   spreadsheet,
//   image,
//   code,
//   other,
// }

// class MaterialItem {
//   final String title;
//   final String description;
//   final MaterialType type;
//   final String url;

//   const MaterialItem({
//     required this.title,
//     required this.description,
//     required this.type,
//     required this.url,
//   });
// }
