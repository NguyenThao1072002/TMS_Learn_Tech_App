import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/practice_test/practice_test_review_model.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';

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
  final PracticeTestUseCase _practiceTestUseCase =
      GetIt.instance<PracticeTestUseCase>();
  final ScrollController _scrollController = ScrollController();

  List<PracticeTestReviewModel> _reviews = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadReviews();

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadReviews();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newReviews = await _practiceTestUseCase.getPracticeTestReviews(
        widget.testId,
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        if (newReviews.isEmpty) {
          _hasMore = false;
        } else {
          _reviews.addAll(newReviews);
          _currentPage++;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải đánh giá: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _buildReviewStats(),
          Expanded(
            child: _reviews.isEmpty && !_isLoading
                ? _buildEmptyState()
                : _buildReviewsList(),
          ),
        ],
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

  Widget _buildReviewsList() {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length + (_hasMore ? 1 : 0),
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == _reviews.length) {
          return _buildLoadingIndicator();
        }

        final review = _reviews[index];
        return _buildReviewItem(review);
      },
    );
  }

  Widget _buildReviewItem(PracticeTestReviewModel review) {
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
                          _formatDate(review.createdAt),
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

  Widget _buildReviewStats() {
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
                    'Đánh giá (${_reviews.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_reviews.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _calculateAverageRating().toStringAsFixed(1),
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

  double _calculateAverageRating() {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold(0, (sum, review) => sum + review.rating);
    return total / _reviews.length;
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
