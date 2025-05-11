import 'package:flutter/material.dart';
import 'package:tms_app/data/models/practice_test/practice_test_detail_model.dart';
import 'package:tms_app/data/models/practice_test/practice_test_review_model.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';
import 'package:tms_app/presentation/screens/practice_test/review_practice_test.dart';

class TestReviewSection extends StatefulWidget {
  final int testId;
  final String testTitle;
  final bool canReview;
  final PracticeTestUseCase practiceTestUseCase;

  const TestReviewSection({
    Key? key,
    required this.testId,
    required this.testTitle,
    required this.canReview,
    required this.practiceTestUseCase,
  }) : super(key: key);

  @override
  State<TestReviewSection> createState() => _TestReviewSectionState();
}

class _TestReviewSectionState extends State<TestReviewSection> {
  late Future<List<PracticeTestReviewModel>> _reviewsFuture;
  bool _showAllReviews = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    _reviewsFuture = widget.practiceTestUseCase.getPracticeTestReviews(
      widget.testId,
      page: 0,
      size: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Đánh giá từ học viên',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Reviews section
        FutureBuilder<List<PracticeTestReviewModel>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Không thể tải đánh giá',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              );
            }

            final reviews = snapshot.data ?? [];
            final displayedReviews = _showAllReviews
                ? reviews
                : (reviews.length > 2 ? reviews.sublist(0, 2) : reviews);
            final hasMoreReviews = reviews.length > 2 && !_showAllReviews;

            if (reviews.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Chưa có đánh giá nào cho đề thi này",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                ...displayedReviews.map((review) => _buildReviewCard(
                      name: review.fullname,
                      avatar: review.image,
                      rating: review.rating.toDouble(),
                      comment: review.review ?? 'Không có đánh giá',
                      date: review.createdAt,
                    )),

                // Xem thêm button
                if (hasMoreReviews)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAllReviews = true;
                          });
                        },
                        icon: const Icon(Icons.unfold_more),
                        label: const Text("Xem thêm đánh giá"),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF3498DB),
                        ),
                      ),
                    ),
                  ),

                // Xem tất cả button
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewPracticeTestScreen(
                              testId: widget.testId,
                              testTitle: widget.testTitle,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.format_list_bulleted),
                      label: Text("Xem tất cả ${reviews.length} đánh giá"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Write review section
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chia sẻ trải nghiệm học tập của bạn",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Đánh giá của bạn sẽ giúp cải thiện chất lượng đề thi và giúp người học khác có lựa chọn phù hợp",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (widget.canReview) {
                      _showAddReviewDialog(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Bạn không thể đánh giá đề thi này vì bạn chưa đăng ký'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Viết đánh giá"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.canReview
                        ? const Color(0xFF3498DB)
                        : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddReviewDialog(BuildContext context) {
    int selectedRating = 5;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Đánh giá đề thi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bạn đánh giá đề thi này thế nào?'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: const Color(0xFFFFC107),
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text('Chia sẻ trải nghiệm của bạn (tùy chọn)'),
                const SizedBox(height: 8),
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Viết đánh giá của bạn',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Use account ID from authentication when available
                const mockAccountId = 1;

                final success =
                    await widget.practiceTestUseCase.submitPracticeTestReview(
                  widget.testId,
                  mockAccountId,
                  selectedRating,
                  review: reviewController.text.isNotEmpty
                      ? reviewController.text
                      : null,
                );

                if (context.mounted) {
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Cảm ơn bạn đã đánh giá!'
                            : 'Không thể gửi đánh giá. Hãy thử lại sau.',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  if (success) {
                    setState(() {
                      _loadReviews();
                    });
                  }
                }
              },
              child: const Text('Gửi đánh giá'),
            ),
          ],
        );
      }),
    ).then((_) {
      // Dispose controller when dialog is closed
      reviewController.dispose();
    });
  }

  Widget _buildReviewCard({
    required String name,
    required String avatar,
    required double rating,
    required String comment,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(avatar),
            onBackgroundImageError: (exception, stackTrace) {},
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < rating.floor()
                            ? Icons.star
                            : index < rating
                                ? Icons.star_half
                                : Icons.star_border,
                        color: const Color(0xFFFFC107),
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  comment,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
