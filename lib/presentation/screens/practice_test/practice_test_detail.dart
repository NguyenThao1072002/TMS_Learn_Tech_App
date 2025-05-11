import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/practice_test/practice_test_detail_model.dart';
import 'package:tms_app/data/models/practice_test/practice_test_review_model.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';
import 'package:tms_app/presentation/widgets/practice_test/related_practice_test.dart';
import 'package:tms_app/presentation/widgets/practice_test/test_review_section.dart';

class PracticeTestDetailScreen extends StatefulWidget {
  final int testId;

  const PracticeTestDetailScreen({Key? key, required this.testId})
      : super(key: key);

  @override
  State<PracticeTestDetailScreen> createState() =>
      _PracticeTestDetailScreenState();
}

class _PracticeTestDetailScreenState extends State<PracticeTestDetailScreen> {
  final PracticeTestUseCase _practiceTestUseCase =
      GetIt.instance<PracticeTestUseCase>();
  late Future<PracticeTestDetailModel?> _testDetailFuture;

  @override
  void initState() {
    super.initState();
    _loadTestDetail();
  }

  void _loadTestDetail() {
    // Get current user ID if available
    int? accountId;
    // User account ID can be obtained from authentication provider when implemented

    _testDetailFuture = _practiceTestUseCase
        .getPracticeTestDetail(
      widget.testId,
      accountId: accountId,
    )
        .then((test) {
      if (test != null) {
        // Add default values if the API doesn't provide the new fields
        final updatedTest = _addDefaultValuesIfNeeded(test);
        return updatedTest;
      }
      return test;
    });
  }

  PracticeTestDetailModel _addDefaultValuesIfNeeded(
      PracticeTestDetailModel test) {
    // If the API doesn't return any values for our new fields, provide some default ones
    List<String> testContents = test.testContents;
    List<String> knowledgeRequirements = test.knowledgeRequirements;

    // Add default values for testContents if empty
    if (testContents.isEmpty) {
      testContents = [
        'Kiến thức core và chuyên sâu về ${test.courseTitle}',
        'Kỹ năng xử lý vấn đề và debug code',
        'Hiểu biết về các best practices và design patterns',
        'Khả năng tối ưu hiệu suất ứng dụng',
      ];
    }

    // Add default values for knowledgeRequirements if empty
    if (knowledgeRequirements.isEmpty) {
      knowledgeRequirements = [
        'Kiến thức cơ bản về lập trình ${test.courseTitle}',
        'Đã từng phát triển ít nhất 1 ứng dụng di động',
        'Hiểu biết về UI/UX và component-based architecture',
      ];
    }

    // Only create a new instance if we've modified any of the fields
    if (testContents != test.testContents ||
        knowledgeRequirements != test.knowledgeRequirements) {
      return PracticeTestDetailModel(
        testId: test.testId,
        title: test.title,
        description: test.description,
        totalQuestion: test.totalQuestion,
        courseId: test.courseId,
        courseTitle: test.courseTitle,
        itemCountPrice: test.itemCountPrice,
        itemCountReview: test.itemCountReview,
        rating: test.rating,
        imageUrl: test.imageUrl,
        level: test.level,
        examType: test.examType,
        status: test.status,
        price: test.price,
        cost: test.cost,
        percentDiscount: test.percentDiscount,
        purchased: test.purchased,
        createdAt: test.createdAt,
        updatedAt: test.updatedAt,
        intro: test.intro,
        author: test.author,
        testContents: testContents,
        knowledgeRequirements: knowledgeRequirements,
      );
    }

    return test;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<PracticeTestDetailModel?>(
        future: _testDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải thông tin đề thi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lỗi: ${snapshot.error}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadTestDetail();
                      });
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy đề thi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mã đề thi: ${widget.testId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            );
          }

          final test = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // App Bar with test image as background
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFF3498DB),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        test.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF3498DB),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    test.courseTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFC107),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${test.rating}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${test.itemCountReview} đánh giá)',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
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
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Test info cards
                      Row(
                        children: [
                          _buildInfoCard(
                            icon: Icons.help_outline,
                            title: '${test.totalQuestion} câu hỏi',
                            subtitle: 'Đa dạng độ khó',
                          ),
                          const SizedBox(width: 12),
                          _buildInfoCard(
                            icon: Icons.access_time,
                            title: '${test.totalQuestion ~/ 2} phút',
                            subtitle: 'Thời gian làm bài',
                          ),
                          const SizedBox(width: 12),
                          _buildInfoCard(
                            icon: Icons.bar_chart,
                            title: _getVietnameseLevel(test.level),
                            subtitle: 'Độ khó',
                            iconColor: _getLevelColor(test.level),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // About this test
                      const Text(
                        'Giới thiệu đề thi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        test.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // What you'll learn
                      const Text(
                        'Bạn sẽ được kiểm tra',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...test.testContents
                          .map((item) => _buildBulletPoint(item)),

                      const SizedBox(height: 24),

                      // Requirements
                      const Text(
                        'Yêu cầu kiến thức',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...test.knowledgeRequirements
                          .map((item) => _buildBulletPoint(item)),

                      const SizedBox(height: 32),

                      // Price and purchase section
                      _buildPriceSection(test),

                      const SizedBox(height: 32),

                      // Reviews section using the widget
                      TestReviewSection(
                        testId: test.testId,
                        testTitle: test.title,
                        canReview: test.purchased,
                        practiceTestUseCase: _practiceTestUseCase,
                      ),

                      const SizedBox(height: 32),

                      // Related tests section
                      RelatedPracticeTest(
                        practiceTestUseCase: _practiceTestUseCase,
                        currentTestId: test.testId,
                        courseId: test.courseId,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<PracticeTestDetailModel?>(
        future: _testDetailFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }

          final test = snapshot.data!;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (test.percentDiscount > 0)
                        Text(
                          '${_formatPrice(test.cost)}đ',
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      Text(
                        test.purchased
                            ? 'Đã mua'
                            : test.price > 0
                                ? '${_formatPrice(test.price)}đ'
                                : 'Miễn phí',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: test.purchased
                              ? Colors.green
                              : const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Start the test or purchase flow
                    if (test.purchased) {
                      // Navigate to test taking screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bắt đầu làm bài thi...'),
                        ),
                      );
                    } else if (test.price > 0) {
                      // Show payment options
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đang mở trang thanh toán...'),
                        ),
                      );
                      // TODO: Implement payment flow
                    } else {
                      // Free test - navigate to test taking screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bắt đầu làm bài thi miễn phí...'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        test.purchased ? Colors.green : const Color(0xFF3498DB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    test.purchased
                        ? 'Làm bài ngay'
                        : test.price > 0
                            ? 'Mua ngay'
                            : 'Làm bài miễn phí',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceSection(PracticeTestDetailModel test) {
    if (test.purchased) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bạn đã mua đề thi này',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bạn có thể làm bài thi ngay bây giờ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giá',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                if (test.percentDiscount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Giảm ${test.percentDiscount}%',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  test.price > 0 ? '${_formatPrice(test.price)}đ' : 'Miễn phí',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: test.price > 0 ? Colors.black : Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                if (test.percentDiscount > 0)
                  Text(
                    '${_formatPrice(test.cost)}đ',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              test.price > 0
                  ? 'Truy cập vĩnh viễn sau khi mua'
                  : 'Bài thi miễn phí - có thể truy cập ngay',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = const Color(0xFF3498DB),
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3498DB),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _getVietnameseLevel(String level) {
    switch (level.toUpperCase()) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      default:
        return level;
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'EASY':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HARD':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
