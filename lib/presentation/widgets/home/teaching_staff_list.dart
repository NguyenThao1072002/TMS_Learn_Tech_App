import 'package:flutter/material.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/data/models/teaching_staff/teaching_staff_model.dart';
import 'package:tms_app/presentation/controller/teaching_staff_controller.dart';
import 'package:tms_app/presentation/screens/homePage/teaching_staff.dart';

class TeachingStaffList extends StatefulWidget {
  final VoidCallback? onViewAll;

  const TeachingStaffList({
    Key? key,
    this.onViewAll,
  }) : super(key: key);

  @override
  State<TeachingStaffList> createState() => _TeachingStaffListState();
}

class _TeachingStaffListState extends State<TeachingStaffList> {
  // Sử dụng singleton instance
  final TeachingStaffController _controller = TeachingStaffController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _controller.getFeaturedTeachingStaffs(limit: 5);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    // No need to remove the listener since we're not adding it anymore
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tiêu đề
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadding,
              vertical: AppDimensions.smallSpacing * 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đội ngũ của chúng tôi',
                style: AppStyles.sectionTitle.copyWith(
                  color: AppStyles.primaryColor,
                ),
              ),
              TextButton(
                onPressed: widget.onViewAll ??
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TeachingStaffScreen(),
                        ),
                      );
                    },
                child: const Text('Xem thêm'),
              ),
            ],
          ),
        ),

        // Team Cards
        Container(
          height: 200,
          margin: EdgeInsets.only(bottom: AppDimensions.blockSpacing),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorWidget()
                  : _buildTeachingStaffList(),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Không thể tải dữ liệu: $_error',
            style: AppStyles.errorText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachingStaffList() {
    final staffList = _controller.featuredTeachingStaffs;

    if (staffList.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có giảng viên nào',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding:
          EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding - 5),
      itemCount: staffList.length,
      itemBuilder: (context, index) {
        final staff = staffList[index];
        return _buildTeamMemberCard(
          staff: staff,
          context: context,
        );
      },
    );
  }

  Widget _buildTeamMemberCard({
    required TeachingStaff staff,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        // Hiển thị chi tiết giảng viên trực tiếp
        _showStaffDetails(context, staff);
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.borderRadius),
                topRight: Radius.circular(AppDimensions.borderRadius),
              ),
              child: Image.network(
                staff.avatarUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.formSpacing),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      staff.fullname,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppDimensions.smallSpacing),
                    Text(
                      staff.categoryName,
                      textAlign: TextAlign.center,
                      style: AppStyles.subText.copyWith(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppDimensions.smallSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          staff.averageRating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${staff.courseCount} khóa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Phương thức để hiển thị chi tiết giảng viên
  void _showStaffDetails(BuildContext context, TeachingStaff staff) async {
    try {
      // Hiển thị loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Lấy thông tin chi tiết
      final staffDetail = await _controller.getTeachingStaffDetailById(staff.id);
      
      // Đóng loading indicator
      Navigator.pop(context);
      
      if (staffDetail != null && mounted) {
        // Hiển thị chi tiết giảng viên trong bottom sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildInstructorDetailsSheet(context, staff),
        );
      }
    } catch (e) {
      // Đóng loading indicator nếu đang hiển thị
      Navigator.of(context, rootNavigator: true).pop();
      print('Error loading staff details: $e');
    }
  }
  
  // Widget hiển thị chi tiết giảng viên trong bottom sheet
  Widget _buildInstructorDetailsSheet(BuildContext context, TeachingStaff staff) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Header with instructor image & name
              Stack(
                children: [
                  // Background gradient
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF3498DB),
                          const Color(0xFF3498DB).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),

                  // Profile content
                  Column(
                    children: [
                      // Handle bar for dragging
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Profile Image
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            staff.avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Instructor name & role
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Text(
                              staff.fullname,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              staff.categoryName,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.library_books_outlined,
                      label: 'Khóa học',
                      value: staff.courseCount.toString(),
                    ),
                    _buildStatItem(
                      icon: Icons.people_outline,
                      label: 'Học viên',
                      value: staff.totalStudents.toString(),
                    ),
                    _buildStatItem(
                      icon: Icons.star_outline,
                      label: 'Đánh giá',
                      value: staff.averageRating.toString(),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Bio/Instruction
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giới thiệu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      staff.instruction,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Expertise
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chuyên môn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      staff.expert,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // View courses button
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: () {
                    // Đóng bottom sheet hiện tại
                    Navigator.pop(context);
                    
                    // Mở màn hình danh sách giảng viên
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TeachingStaffScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF3498DB)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Xem khóa học',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3498DB),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF3498DB),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
