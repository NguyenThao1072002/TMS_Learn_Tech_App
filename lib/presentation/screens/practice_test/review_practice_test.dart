import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tms_app/data/models/practice_test/practice_test_review_model.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';
import 'package:tms_app/presentation/controller/review_practice_test_controller.dart';

class ReviewPracticeTestScreen extends StatefulWidget {
  final int testId;
  final String testTitle;
  final bool isDarkMode;

  const ReviewPracticeTestScreen({
    Key? key,
    required this.testId,
    required this.testTitle,
    this.isDarkMode = false,
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
    final backgroundColor = widget.isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = widget.isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
    final appBarColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final cardColor = widget.isDarkMode ? const Color(0xFF2A2D3E) : Colors.white;
    final cardBorderColor = widget.isDarkMode ? const Color(0xFF3A3F55) : Colors.grey.shade200;
    
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
            backgroundColor: backgroundColor,
            appBar: AppBar(
              title: Text(
                'Đánh giá ${widget.testTitle}',
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              backgroundColor: appBarColor,
              foregroundColor: textColor,
              elevation: 1,
            ),
            body: Column(
              children: [
                _buildReviewStats(controller, cardColor, textColor, secondaryTextColor, cardBorderColor),
                Expanded(
                  child: controller.reviews.isEmpty && !controller.isLoading
                      ? _buildEmptyState(textColor, secondaryTextColor)
                      : _buildReviewsList(controller, cardColor, textColor, secondaryTextColor, cardBorderColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color secondaryTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: widget.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có đánh giá nào',
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy là người đầu tiên đánh giá đề thi này',
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(
    ReviewPracticeTestController controller, 
    Color cardColor, 
    Color textColor, 
    Color secondaryTextColor,
    Color cardBorderColor
  ) {
    return ListView.separated(
      controller: controller.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: controller.reviews.length + (controller.hasMore ? 1 : 0),
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        if (index == controller.reviews.length) {
          return _buildLoadingIndicator();
        }

        final review = controller.reviews[index];
        return _buildReviewItem(review, controller, cardColor, textColor, secondaryTextColor, cardBorderColor);
      },
    );
  }

  Widget _buildReviewItem(
    PracticeTestReviewModel review, 
    ReviewPracticeTestController controller,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color cardBorderColor
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review.image),
                onBackgroundImageError: (e, s) {},
                backgroundColor: widget.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.fullname,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor,
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
                            color: secondaryTextColor,
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
                  color: secondaryTextColor,
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

  Widget _buildReviewStats(
    ReviewPracticeTestController controller,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
    Color cardBorderColor
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: cardBorderColor,
            width: 1,
          ),
        ),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          ' / 5',
                          style: TextStyle(
                            color: secondaryTextColor,
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
                  side: const BorderSide(color: Color(0xFF3498DB)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
