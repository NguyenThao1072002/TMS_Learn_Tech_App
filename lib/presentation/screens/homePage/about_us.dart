import 'package:flutter/material.dart';
import 'package:tms_app/core/theme/app_styles.dart';
import 'package:tms_app/core/theme/app_dimensions.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar có hiệu ứng co giãn
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: AppStyles.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Về TMS Learn Tech',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(100, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://img.freepik.com/free-vector/gradient-technology-background_23-2149116941.jpg',
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black45,
                        ],
                      ),
                    ),
                  ),
                  // Logo overlay
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.school,
                            color: AppStyles.primaryColor,
                            size: AppDimensions.iconSize * 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Chức năng chia sẻ
                },
              ),
            ],
          ),
          // Nội dung chính
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tagline
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.blockSpacing,
                      horizontal: AppDimensions.screenPadding),
                  color: AppStyles.primaryColor,
                  child: Column(
                    children: [
                      Text(
                        'NỀN TẢNG HỌC TẬP CÔNG NGHỆ HÀNG ĐẦU',
                        textAlign: TextAlign.center,
                        style: AppStyles.whiteTitle.copyWith(
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: AppDimensions.smallSpacing * 2),
                      Text(
                        'Nâng tầm kỹ năng công nghệ của bạn cùng TMS Learn Tech',
                        textAlign: TextAlign.center,
                        style: AppStyles.italicWhite,
                      ),
                    ],
                  ),
                ),

                // Mission
                _buildModernSection(
                  context,
                  icon: Icons.lightbulb_outline,
                  title: 'Sứ mệnh của chúng tôi',
                  content:
                      'TMS Learn Tech ra đời với sứ mệnh cung cấp nền tảng học tập công nghệ chất lượng cao, giúp người học dễ dàng tiếp cận kiến thức và phát triển kỹ năng trong lĩnh vực công nghệ thông tin.',
                  color: AppStyles.primaryColor,
                ),

                // Vision
                _buildModernSection(
                  context,
                  icon: Icons.visibility_outlined,
                  title: 'Tầm nhìn',
                  content:
                      'Trở thành nền tảng học tập công nghệ hàng đầu tại Việt Nam, nơi kết nối tri thức và kinh nghiệm từ các chuyên gia đến người học, góp phần đào tạo nguồn nhân lực chất lượng cao.',
                  color: const Color(0xFF2ECC71), // Màu xanh lá
                ),

                // Core Values
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: AppDimensions.blockSpacing,
                      horizontal: AppDimensions.screenPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadius),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C), // Màu đỏ
                          borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(AppDimensions.borderRadius),
                            topRight:
                                Radius.circular(AppDimensions.borderRadius),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: AppDimensions.smallSpacing * 2),
                            Text(
                              'Giá trị cốt lõi',
                              style: AppStyles.whiteTitle.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(1, 1),
                                    blurRadius: 3.0,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(AppDimensions.blockSpacing),
                        child: Column(
                          children: [
                            _buildValueCard(
                              title: 'Chất lượng',
                              content:
                                  'Cam kết cung cấp các khóa học chất lượng cao với nội dung cập nhật, thực tiễn.',
                              icon: Icons.verified_outlined,
                              color: AppStyles.primaryColor,
                            ),
                            _buildValueCard(
                              title: 'Đổi mới',
                              content:
                                  'Không ngừng đổi mới phương pháp giảng dạy và nền tảng học tập.',
                              icon: Icons.auto_awesome,
                              color: const Color(0xFF9B59B6), // Màu tím
                            ),
                            _buildValueCard(
                              title: 'Tinh thần phục vụ',
                              content:
                                  'Lấy người học làm trung tâm, hỗ trợ học viên trong suốt quá trình học tập.',
                              icon: Icons.support_agent,
                              color: const Color(0xFF2ECC71),
                            ),
                            _buildValueCard(
                              title: 'Cộng đồng',
                              content:
                                  'Xây dựng cộng đồng học tập vững mạnh, chia sẻ và phát triển cùng nhau.',
                              icon: Icons.people_alt_outlined,
                              color: const Color(0xFFE67E22), // Màu cam
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Team
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPadding,
                      vertical: AppDimensions.smallSpacing * 2),
                  child: Text(
                    'Đội ngũ của chúng tôi',
                    style: AppStyles.sectionTitle.copyWith(
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ),

                // Team Cards
                Container(
                  height: 200,
                  margin:
                      EdgeInsets.only(bottom: AppDimensions.blockSpacing + 10),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.screenPadding - 5),
                    children: [
                      _buildTeamMemberCard(
                        name: 'Nguyễn Văn A',
                        role: 'Giảng viên AI & Machine Learning',
                        imageUrl:
                            'https://randomuser.me/api/portraits/men/32.jpg',
                        context: context,
                      ),
                      _buildTeamMemberCard(
                        name: 'Trần Thị B',
                        role: 'Giảng viên Web Development',
                        imageUrl:
                            'https://randomuser.me/api/portraits/women/44.jpg',
                        context: context,
                      ),
                      _buildTeamMemberCard(
                        name: 'Lê Văn C',
                        role: 'Giảng viên Mobile Development',
                        imageUrl:
                            'https://randomuser.me/api/portraits/men/46.jpg',
                        context: context,
                      ),
                    ],
                  ),
                ),

                // Contact
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenPadding,
                      vertical: AppDimensions.smallSpacing * 2),
                  padding: EdgeInsets.all(AppDimensions.blockSpacing),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppStyles.primaryColor, const Color(0xFF2980B9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Liên hệ với chúng tôi',
                        style: AppStyles.whiteTitle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppDimensions.formSpacing + 3),
                      _buildContactItem(Icons.location_on_outlined,
                          'Trường Đại học Công Thương TP. HCM'),
                      _buildContactItem(
                          Icons.email_outlined, 'tms.huit@gmail.com'),
                      _buildContactItem(Icons.phone_outlined, '0348740942'),
                      _buildContactItem(
                          Icons.facebook, 'facebook.com/ha.nam.213230'),
                      _buildContactItem(Icons.language, 'tmslearntech.io.vn'),
                    ],
                  ),
                ),

                // Call to Action
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: AppDimensions.headingSpacing + 6,
                      horizontal: AppDimensions.screenPadding),
                  padding: EdgeInsets.all(AppDimensions.blockSpacing + 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadius),
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
                      Text(
                        'Sẵn sàng để học hỏi?',
                        style: AppStyles.sectionTitle.copyWith(
                          color: AppStyles.primaryColor,
                        ),
                      ),
                      SizedBox(height: AppDimensions.smallSpacing * 2),
                      Text(
                        'Khám phá hàng trăm khóa học công nghệ với TMS Learn Tech ngay hôm nay',
                        textAlign: TextAlign.center,
                        style: AppStyles.subText,
                      ),
                      SizedBox(height: AppDimensions.blockSpacing),
                      ElevatedButton(
                        onPressed: () {
                          // Điều hướng đến trang Home
                          Navigator.pop(
                              context); // Quay về trang trước đó (Home)
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.headingSpacing + 6,
                              vertical: AppDimensions.formSpacing + 3),
                          backgroundColor: AppStyles.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusRounded),
                          ),
                        ),
                        child: Text(
                          'Khám phá khóa học',
                          style: AppStyles.whiteButtonText.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.blockSpacing),
                  color: const Color(0xFF2C3E50),
                  child: Column(
                    children: [
                      Text(
                        '© 2025 TMS Learn Tech',
                        textAlign: TextAlign.center,
                        style: AppStyles.subText.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: AppDimensions.smallSpacing),
                      Text(
                        'Bảo lưu mọi quyền',
                        textAlign: TextAlign.center,
                        style: AppStyles.subText.copyWith(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPadding,
          vertical: AppDimensions.smallSpacing * 2),
      padding: EdgeInsets.all(AppDimensions.blockSpacing),
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
        border: Border(
          left: BorderSide(
            color: color,
            width: 5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              SizedBox(width: AppDimensions.smallSpacing * 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.formSpacing + 3),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    bool isLast = false,
  }) {
    return Container(
      margin:
          EdgeInsets.only(bottom: isLast ? 0 : AppDimensions.formSpacing + 3),
      padding: EdgeInsets.all(AppDimensions.formSpacing + 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius - 2),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.smallSpacing * 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadius - 2),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(width: AppDimensions.formSpacing + 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.whiteTitle.copyWith(
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: AppDimensions.smallSpacing),
                Text(
                  content,
                  style: AppStyles.subText.copyWith(
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.smallSpacing * 2),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          SizedBox(width: AppDimensions.smallSpacing * 2),
          Text(
            text,
            style: AppStyles.subText.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
