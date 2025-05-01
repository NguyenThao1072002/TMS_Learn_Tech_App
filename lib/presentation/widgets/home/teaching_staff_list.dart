import 'package:flutter/material.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';
import 'package:tms_app/core/theme/app_styles.dart';

class TeachingStaffList extends StatelessWidget {
  final VoidCallback? onViewAll;

  const TeachingStaffList({
    Key? key,
    this.onViewAll,
  }) : super(key: key);

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
                onPressed: onViewAll ??
                    () {
                      Navigator.pushNamed(context, '/about_us');
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
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPadding - 5),
            children: [
              _buildTeamMemberCard(
                name: 'Nguyễn Văn A',
                role: 'Giảng viên AI & Machine Learning',
                imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
                context: context,
              ),
              _buildTeamMemberCard(
                name: 'Trần Thị B',
                role: 'Giảng viên Web Development',
                imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
                context: context,
              ),
              _buildTeamMemberCard(
                name: 'Lê Văn C',
                role: 'Giảng viên Mobile Development',
                imageUrl: 'https://randomuser.me/api/portraits/men/46.jpg',
                context: context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMemberCard({
    required String name,
    required String role,
    required String imageUrl,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to teaching staff screen when a team member card is clicked
        Navigator.pushNamed(context, '/teaching_staff');
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
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppDimensions.formSpacing),
              child: Column(
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: AppDimensions.smallSpacing),
                  Text(
                    role,
                    textAlign: TextAlign.center,
                    style: AppStyles.subText.copyWith(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
