import 'package:flutter/material.dart';

class TeachingStaffScreen extends StatefulWidget {
  const TeachingStaffScreen({Key? key}) : super(key: key);

  @override
  State<TeachingStaffScreen> createState() => _TeachingStaffScreenState();
}

class _TeachingStaffScreenState extends State<TeachingStaffScreen> {
  // Filter options
  final List<String> _categories = [
    'Tất cả',
    'Web Development',
    'Mobile Development',
    'AI & Machine Learning',
    'Data Science',
    'UI/UX Design',
  ];

  String _selectedCategory = 'Tất cả';
  TextEditingController _searchController = TextEditingController();

  // Mock data for instructors
  final List<Map<String, dynamic>> _instructors = [
    {
      'name': 'Nguyễn Văn A',
      'role': 'Giảng viên AI & Machine Learning',
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
      'courses': 12,
      'students': 1450,
      'rating': 4.8,
      'category': 'AI & Machine Learning',
      'expertise': ['Machine Learning', 'Deep Learning', 'Computer Vision'],
      'bio':
          'Tiến sĩ về AI tại Đại học Stanford với hơn 10 năm kinh nghiệm giảng dạy và nghiên cứu trong lĩnh vực Machine Learning và AI.',
    },
    {
      'name': 'Trần Thị B',
      'role': 'Giảng viên Web Development',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'courses': 8,
      'students': 1280,
      'rating': 4.9,
      'category': 'Web Development',
      'expertise': ['ReactJS', 'NodeJS', 'JavaScript', 'TypeScript'],
      'bio':
          'Chuyên gia Frontend với hơn 8 năm kinh nghiệm phát triển web. Từng làm việc tại Google và các công ty công nghệ hàng đầu.',
    },
    {
      'name': 'Lê Văn C',
      'role': 'Giảng viên Mobile Development',
      'image': 'https://randomuser.me/api/portraits/men/46.jpg',
      'courses': 6,
      'students': 950,
      'rating': 4.7,
      'category': 'Mobile Development',
      'expertise': ['Flutter', 'React Native', 'iOS', 'Android'],
      'bio':
          'Phát triển hơn 20 ứng dụng mobile với hàng triệu lượt tải. Chuyên gia về Flutter và React Native.',
    },
    {
      'name': 'Phạm Thị D',
      'role': 'Giảng viên Data Science',
      'image': 'https://randomuser.me/api/portraits/women/33.jpg',
      'courses': 5,
      'students': 820,
      'rating': 4.6,
      'category': 'Data Science',
      'expertise': ['Python', 'SQL', 'Data Analysis', 'Visualization'],
      'bio':
          'Chuyên gia phân tích dữ liệu với kinh nghiệm làm việc tại các tổ chức tài chính và nghiên cứu hàng đầu.',
    },
    {
      'name': 'Hoàng Văn E',
      'role': 'Giảng viên UI/UX Design',
      'image': 'https://randomuser.me/api/portraits/men/36.jpg',
      'courses': 7,
      'students': 1100,
      'rating': 4.9,
      'category': 'UI/UX Design',
      'expertise': ['Figma', 'Adobe XD', 'User Research', 'Prototyping'],
      'bio':
          'Nhà thiết kế UX với hơn 12 năm kinh nghiệm. Từng thiết kế cho các thương hiệu lớn và startups thành công.',
    },
    {
      'name': 'Nguyễn Thị F',
      'role': 'Giảng viên Web Development',
      'image': 'https://randomuser.me/api/portraits/women/22.jpg',
      'courses': 9,
      'students': 1300,
      'rating': 4.8,
      'category': 'Web Development',
      'expertise': ['Angular', 'Vue.js', 'PHP', 'Laravel'],
      'bio':
          'Full-stack developer với kinh nghiệm xây dựng các ứng dụng web quy mô lớn và hiệu suất cao.',
    },
  ];

  List<Map<String, dynamic>> _filteredInstructors = [];

  @override
  void initState() {
    super.initState();
    _filteredInstructors = List.from(_instructors);
    _searchController.addListener(_filterInstructors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterInstructors() {
    setState(() {
      final String query = _searchController.text.toLowerCase();
      _filteredInstructors = _instructors.where((instructor) {
        final bool matchesCategory = _selectedCategory == 'Tất cả' ||
            instructor['category'] == _selectedCategory;

        final bool matchesSearch =
            instructor['name'].toLowerCase().contains(query) ||
                instructor['role'].toLowerCase().contains(query) ||
                instructor['bio'].toLowerCase().contains(query);

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filterInstructors();
    });
  }

  void _showInstructorDetails(Map<String, dynamic> instructor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildInstructorDetailsSheet(instructor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Đội ngũ giảng viên',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show information about instructors
              _showInfoDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm giảng viên...',
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final String category = _categories[index];
                final bool isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF3498DB),
                    backgroundColor: Colors.grey[100],
                    onSelected: (_) => _selectCategory(category),
                  ),
                );
              },
            ),
          ),

          // Instructors Grid
          Expanded(
            child: _filteredInstructors.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy giảng viên phù hợp',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.60,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredInstructors.length,
                    itemBuilder: (context, index) {
                      final instructor = _filteredInstructors[index];
                      return _buildInstructorCard(instructor);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Find instructor functionality
          _showSuggestInstructorDialog();
        },
        backgroundColor: const Color(0xFF3498DB),
        child: const Icon(Icons.lightbulb_outline),
        tooltip: 'Gợi ý giảng viên',
      ),
    );
  }

  // Helper methods for UI components
  Widget _buildInstructorCard(Map<String, dynamic> instructor) {
    return GestureDetector(
      onTap: () => _showInstructorDetails(instructor),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Instructor image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF3498DB).withOpacity(0.2),
                      const Color(0xFF3498DB).withOpacity(0.05),
                    ],
                  ),
                ),
                child: Image.network(
                  instructor['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Instructor info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      instructor['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      instructor['role'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              instructor['rating'].toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.library_books_outlined,
                              color: Color(0xFF3498DB),
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${instructor['courses']} khóa',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
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

  Widget _buildInstructorDetailsSheet(Map<String, dynamic> instructor) {
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
                            instructor['image'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Instructor name & role
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Text(
                              instructor['name'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              instructor['role'],
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
                      value: instructor['courses'].toString(),
                    ),
                    _buildStatItem(
                      icon: Icons.people_outline,
                      label: 'Học viên',
                      value: instructor['students'].toString(),
                    ),
                    _buildStatItem(
                      icon: Icons.star_outline,
                      label: 'Đánh giá',
                      value: instructor['rating'].toString(),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Bio
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
                      instructor['bio'],
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final skill in instructor['expertise'])
                          Chip(
                            label: Text(skill),
                            backgroundColor: const Color(0xFFE1F5FE),
                            labelStyle: const TextStyle(
                              color: Color(0xFF3498DB),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // View courses button
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: () {
                    // Action to view instructor's courses
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Xem khóa học của ${instructor['name']}'),
                        behavior: SnackBarBehavior.floating,
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

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về đội ngũ giảng viên'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Đội ngũ giảng viên của TMS Learn Tech',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Đội ngũ giảng viên của chúng tôi bao gồm các chuyên gia hàng đầu trong nhiều lĩnh vực công nghệ khác nhau. Tất cả giảng viên đều có kinh nghiệm thực tế phong phú và kỹ năng giảng dạy xuất sắc.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                'Các giảng viên được tuyển chọn kỹ lưỡng và đào tạo bài bản để đảm bảo chất lượng giảng dạy tốt nhất cho học viên. Họ không chỉ là những người hướng dẫn mà còn là người cố vấn, sẵn sàng hỗ trợ học viên trong suốt quá trình học tập.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showSuggestInstructorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gợi ý giảng viên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chúng tôi có thể giúp bạn tìm giảng viên phù hợp với nhu cầu học tập của bạn.',
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập chủ đề bạn muốn học...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã gửi yêu cầu tìm giảng viên'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
            ),
            child: const Text('Tìm giảng viên'),
          ),
        ],
      ),
    );
  }
}
