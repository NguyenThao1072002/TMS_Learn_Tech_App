import 'package:flutter/material.dart';

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
            backgroundColor: const Color(0xFF3498DB), // Màu xanh dương sáng
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
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Color(0xFF3498DB),
                            size: 60,
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  color: const Color(0xFF3498DB),
                  child: const Column(
                    children: [
                      Text(
                        'NỀN TẢNG HỌC TẬP CÔNG NGHỆ HÀNG ĐẦU',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Nâng tầm kỹ năng công nghệ của bạn cùng TMS Learn Tech',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
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
                  color: const Color(0xFF3498DB),
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
                  margin:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                        decoration: const BoxDecoration(
                          color: Color(0xFFE74C3C), // Màu đỏ
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Giá trị cốt lõi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildValueCard(
                              title: 'Chất lượng',
                              content:
                                  'Cam kết cung cấp các khóa học chất lượng cao với nội dung cập nhật, thực tiễn.',
                              icon: Icons.verified_outlined,
                              color: const Color(0xFF3498DB),
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text(
                    'Đội ngũ của chúng tôi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3498DB),
                    ),
                  ),
                ),

                // Team Cards
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 30),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
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
                      const Text(
                        'Liên hệ với chúng tôi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
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
                  margin:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                      const Text(
                        'Sẵn sàng để học hỏi?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3498DB),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Khám phá hàng trăm khóa học công nghệ với TMS Learn Tech ngay hôm nay',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Điều hướng đến trang Home
                          Navigator.pop(
                              context); // Quay về trang trước đó (Home)
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          backgroundColor: const Color(0xFF3498DB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Khám phá khóa học',
                          style: TextStyle(
                            fontSize: 16,
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
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color: const Color(0xFF2C3E50),
                  child: const Column(
                    children: [
                      Text(
                        '© 2025 TMS Learn Tech',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Bảo lưu mọi quyền',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
              const SizedBox(width: 10),
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
          const SizedBox(height: 15),
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
      margin: EdgeInsets.only(bottom: isLast ? 0 : 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
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
          borderRadius: BorderRadius.circular(15),
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
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.network(
                imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
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
                  const SizedBox(height: 5),
                  Text(
                    role,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
