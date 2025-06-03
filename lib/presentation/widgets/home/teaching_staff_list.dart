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

    // Đăng ký lắng nghe thay đổi
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
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
    // Hủy đăng ký lắng nghe khi widget bị hủy
    _controller.removeListener(_onControllerChanged);
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
          id: staff.id,
          name: staff.fullname,
          role: staff.categoryName,
          imageUrl: staff.avatarUrl,
          rating: staff.averageRating,
          courses: staff.courseCount,
          context: context,
        );
      },
    );
  }

  Widget _buildTeamMemberCard({
    required int id,
    required String name,
    required String role,
    required String imageUrl,
    required double rating,
    required int courses,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to teaching staff screen with specific staff details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TeachingStaffScreen(),
          ),
        );
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
                imageUrl,
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
                      name,
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
                      role,
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
                          rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '$courses khóa',
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
}
