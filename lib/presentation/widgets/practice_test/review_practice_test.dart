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

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    _reviewsFuture = widget.practiceTestUseCase.getPracticeTestReviews(
      widget.testId,
      page: 0,
      size: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            if (widget.canReview)
              TextButton(
                onPressed: () {
                  // Show review dialog
                  _showAddReviewDialog(context);
                },
                child: const Text('Viết đánh giá'),
              ),
          ],
        ),
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
            // Show max 2 reviews on the detail page
            final displayedReviews = reviews.take(2).toList();
            final hasMoreReviews = reviews.length > 2;

            if (!widget.canReview) {
              // Purchase requirement notice - simplified
              return Column(
                children: [
                  if (displayedReviews.isNotEmpty)
                    ...displayedReviews.map((review) => _buildReviewCard(
                          name: review.fullname,
                          avatar: review.image,
                          rating: review.rating.toDouble(),
                          comment: review.review ?? 'Không có đánh giá',
                          date: review.createdAt,
                        )),
                  if (hasMoreReviews)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextButton.icon(
                        onPressed: () {
                          // Navigate to full reviews screen
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
                        icon: const Icon(Icons.arrow_forward),
                        label: Text('Xem tất cả ${reviews.length} đánh giá'),
                      ),
                    ),
                  if (reviews.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Chưa có đánh giá nào',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Bạn không thể đánh giá đề thi này vì bạn chưa đăng ký',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (reviews.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        'Chưa có đánh giá nào',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddReviewDialog(context),
                        icon: const Icon(Icons.rate_review),
                        label: const Text('Đánh giá ngay'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
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
                // Add button to see all reviews
                if (hasMoreReviews)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextButton.icon(
                      onPressed: () {
                        // Navigate to full reviews screen
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
                      icon: const Icon(Icons.arrow_forward),
                      label: Text('Xem tất cả ${reviews.length} đánh giá'),
                    ),
                  ),
                // Add button for users to leave review
                if (widget.canReview)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton.icon(
                      onPressed: () => _showAddReviewDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm đánh giá của bạn'),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showAddReviewDialog(BuildContext context) {
    // Continue with review dialog if purchased
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(avatar),
                onBackgroundImageError: (exception, stackTrace) {},
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
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
