import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/data/models/practice_test/practice_test_review_model.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';
import 'package:tms_app/presentation/controller/review_practice_test_controller.dart';

class ReviewPracticeTestScreen extends StatefulWidget {
  final int testId;
  final String testTitle;

  const ReviewPracticeTestScreen({
    Key? key,
    required this.testId,
    required this.testTitle,
  }) : super(key: key);

  @override
  State<ReviewPracticeTestScreen> createState() =>
      _ReviewPracticeTestScreenState();
}

class _ReviewPracticeTestScreenState extends State<ReviewPracticeTestScreen> {
  late ReviewPracticeTestController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReviewPracticeTestController(testId: widget.testId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ReviewPracticeTestController>(
        builder: (context, controller, _) {
          // Show error message if there's one
          if (controller.errorMessage.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.errorMessage)),
                );
                // Reset error message after showing
                controller.errorMessage = '';
              }
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Đánh giá ${widget.testTitle}',
                style: const TextStyle(fontSize: 18),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            ),
            body: Column(
              children: [
                _buildReviewStats(controller),
                Expanded(
                  child: controller.reviews.isEmpty && !controller.isLoading
                      ? _buildEmptyState()
                      : _buildReviewsList(controller),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có đánh giá nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy là người đầu tiên đánh giá đề thi này',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(ReviewPracticeTestController controller) {
    return ListView.separated(
      controller: controller.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: controller.reviews.length + (controller.hasMore ? 1 : 0),
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == controller.reviews.length) {
          return _buildLoadingIndicator();
        }

        final review = controller.reviews[index];
        return _buildReviewItem(review, controller);
      },
    );
  }

  Widget _buildReviewItem(
      PracticeTestReviewModel review, ReviewPracticeTestController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review.image),
                onBackgroundImageError: (e, s) {},
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.fullname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFFFC107),
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          controller.formatDate(review.createdAt),
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
          if (review.review != null && review.review!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 52),
              child: Text(
                review.review!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildReviewStats(ReviewPracticeTestController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đánh giá (${controller.reviews.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (controller.reviews.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller
                              .calculateAverageRating()
                              .toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' / 5',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement write review functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đang được phát triển'),
                    ),
                  );
                },
                icon: const Icon(Icons.rate_review),
                label: const Text('Viết đánh giá'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3498DB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
