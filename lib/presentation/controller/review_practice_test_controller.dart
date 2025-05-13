import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tms_app/data/models/practice_test/practice_test_review_model.dart';
import 'package:tms_app/domain/usecases/practice_test_usecase.dart';

class ReviewPracticeTestController with ChangeNotifier {
  final PracticeTestUseCase _practiceTestUseCase =
      GetIt.instance<PracticeTestUseCase>();
  final ScrollController scrollController = ScrollController();

  List<PracticeTestReviewModel> _reviews = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  final int testId;
  String _errorMessage = '';

  // Getters
  List<PracticeTestReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // Getter and setter for error message
  String get errorMessage => _errorMessage;
  set errorMessage(String value) {
    _errorMessage = value;
    notifyListeners();
  }

  ReviewPracticeTestController({required this.testId}) {
    _setupScrollListener();
    loadReviews();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        loadReviews();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadReviews() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newReviews = await _practiceTestUseCase.getPracticeTestReviews(
        testId,
        page: _currentPage,
        size: _pageSize,
      );

      if (newReviews.isEmpty) {
        _hasMore = false;
      } else {
        _reviews.addAll(newReviews);
        _currentPage++;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Không thể tải đánh giá: ${e.toString()}';
      notifyListeners();
    }
  }

  double calculateAverageRating() {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold(0, (sum, review) => sum + review.rating);
    return total / _reviews.length;
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
