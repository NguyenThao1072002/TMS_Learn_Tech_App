import 'package:flutter/material.dart';
import 'package:tms_app/presentation/screens/practice_test/practice_test_detail.dart';

class PracticeTest {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int questionCount;
  final int price;
  final bool isPurchased;
  final String category;
  final double rating;
  final int ratingCount;

  PracticeTest({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.questionCount,
    required this.price,
    required this.isPurchased,
    required this.category,
    required this.rating,
    required this.ratingCount,
  });
}

class PracticeTestListScreen extends StatefulWidget {
  const PracticeTestListScreen({Key? key}) : super(key: key);

  @override
  State<PracticeTestListScreen> createState() => _PracticeTestListScreenState();
}

class _PracticeTestListScreenState extends State<PracticeTestListScreen> {
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = [
    'Tất cả',
    'Flutter',
    'React Native',
    'Mobile Dev',
    'Frontend',
    'Backend',
  ];

  // Mock data
  final List<PracticeTest> _tests = [
    PracticeTest(
      id: '1',
      title: 'Flutter UI Components Professional Test',
      description: 'Kiểm tra kiến thức sâu về Widget và UI trong Flutter',
      imageUrl: 'https://miro.medium.com/max/1400/1*TFZQzyVAHLVXI_wNreokGA.png',
      questionCount: 50,
      price: 199000,
      isPurchased: false,
      category: 'Flutter',
      rating: 4.8,
      ratingCount: 124,
    ),
    PracticeTest(
      id: '2',
      title: 'State Management Expert',
      description: 'Làm chủ các kỹ thuật quản lý state trong Flutter',
      imageUrl:
          'https://appinventiv.com/wp-content/uploads/sites/1/2019/09/Flutter-1.14-Whats-New-and-Changed.png',
      questionCount: 45,
      price: 249000,
      isPurchased: true,
      category: 'Flutter',
      rating: 4.9,
      ratingCount: 98,
    ),
    PracticeTest(
      id: '3',
      title: 'React Native Components',
      description:
          'Đề thi về các component cơ bản và nâng cao trong React Native',
      imageUrl:
          'https://www.datocms-assets.com/45470/1631110818-logo-react-native.png',
      questionCount: 40,
      price: 179000,
      isPurchased: false,
      category: 'React Native',
      rating: 4.7,
      ratingCount: 87,
    ),
    PracticeTest(
      id: '4',
      title: 'Mobile Architecture Patterns',
      description:
          'Kiểm tra kiến thức về các mẫu kiến trúc trong phát triển ứng dụng di động',
      imageUrl: 'https://miro.medium.com/max/1400/1*yjH3SiDaVWtpBX0g_2q68g.png',
      questionCount: 35,
      price: 299000,
      isPurchased: false,
      category: 'Mobile Dev',
      rating: 4.6,
      ratingCount: 56,
    ),
    PracticeTest(
      id: '5',
      title: 'Frontend Developer Skills Test',
      description: 'Đánh giá kỹ năng phát triển frontend toàn diện',
      imageUrl:
          'https://cdn.sanity.io/images/tlr8oxjg/production/92f95a63f248182a4b659860da75a2dd05375d31-1456x816.png',
      questionCount: 60,
      price: 349000,
      isPurchased: false,
      category: 'Frontend',
      rating: 4.9,
      ratingCount: 142,
    ),
  ];

  List<PracticeTest> get filteredTests {
    if (_selectedCategory == 'Tất cả') {
      return _tests;
    }
    return _tests.where((test) => test.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Bộ đề thi',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF333333)),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF333333)),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3498DB).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Premium Tests',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mở khóa tất cả các đề thi để nâng cao kỹ năng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF3498DB),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/premium_badge.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    width: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category filter
          Container(
            height: 50,
            margin: const EdgeInsets.only(top: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3498DB)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3498DB)
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Test list
          Expanded(
            child: filteredTests.isEmpty
                ? const Center(
                    child: Text(
                      'Không có đề thi nào trong danh mục này',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredTests.length,
                    itemBuilder: (context, index) {
                      final test = filteredTests[index];
                      return _buildTestCard(test);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(PracticeTest test) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PracticeTestDetailScreen(test: test),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                test.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          test.category,
                          style: const TextStyle(
                            color: Color(0xFF3498DB),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFC107),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${test.rating} (${test.ratingCount})',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    test.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    test.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Info row
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${test.questionCount} câu hỏi',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${test.questionCount ~/ 2} phút',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price and button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      test.isPurchased
                          ? Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Đã mua',
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              '${(test.price / 1000).toStringAsFixed(0)}K VND',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Color(0xFF333333),
                              ),
                            ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PracticeTestDetailScreen(test: test),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: test.isPurchased
                              ? const Color(0xFF3498DB)
                              : const Color(0xFF333333),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          test.isPurchased ? 'Làm bài' : 'Xem chi tiết',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
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
