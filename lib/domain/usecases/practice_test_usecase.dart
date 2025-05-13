import 'package:tms_app/data/models/practice_test/practice_test_card_model.dart';
import 'package:tms_app/data/models/practice_test/practice_test_detail_model.dart';
import 'package:tms_app/data/models/practice_test/practice_test_review_model.dart';
import 'package:tms_app/domain/repositories/practice_test_repository.dart';

class PracticeTestUseCase {
  final PracticeTestRepository practiceTestRepository;

  PracticeTestUseCase(this.practiceTestRepository);

  Future<List<PracticeTestCardModel>> getPracticeTests({
    int? courseId,
    int? accountId,
    int page = 0,
    int size = 10,
    String? search,
  }) async {
    return await practiceTestRepository.getPracticeTests(
      courseId: courseId,
      accountId: accountId,
      page: page,
      size: size,
      search: search,
    );
  }

  Future<PracticeTestDetailModel?> getPracticeTestDetail(
    int testId, {
    int? accountId,
  }) async {
    return await practiceTestRepository.getPracticeTestDetail(
      testId,
      accountId: accountId,
    );
  }

  Future<List<PracticeTestReviewModel>> getPracticeTestReviews(
    int testId, {
    int page = 0,
    int size = 10,
  }) async {
    return await practiceTestRepository.getPracticeTestReviews(
      testId,
      page: page,
      size: size,
    );
  }

  Future<bool> submitPracticeTestReview(
    int testId,
    int accountId,
    int rating, {
    String? review,
  }) async {
    return await practiceTestRepository.submitPracticeTestReview(
      testId,
      accountId,
      rating,
      review: review,
    );
  }

  Future<List<Map<String, dynamic>>> getPracticeTestCategories() async {
    return await practiceTestRepository.getPracticeTestCategories();
  }

  Future<List<PracticeTestCardModel>> getFilteredPracticeTests({
    String? title,
    int? courseId,
    int? accountId,
    String? level,
    String? examType,
    double? minPrice,
    double? maxPrice,
    int? minDiscount,
    int? maxDiscount,
    String? author,
    int? categoryId,
    int page = 0,
    int size = 10,
  }) async {
    // First get all practice tests with basic filters
    // If categoryId is provided, use it as courseId parameter
    final effectiveCourseId = categoryId ?? courseId;

    final tests = await practiceTestRepository.getPracticeTests(
      search: title,
      courseId: effectiveCourseId,
      accountId: accountId,
      page: page,
      size: size,
    );

    // Apply additional filters in memory
    return tests.where((test) {
      // Filter by level if specified
      if (level != null && level.isNotEmpty && test.level != level) {
        return false;
      }

      // Filter by exam type if specified (FREE or FEE)
      if (examType != null &&
          examType.isNotEmpty &&
          test.examType != examType) {
        return false;
      }

      // Filter by price range
      if (minPrice != null && test.price < minPrice) {
        return false;
      }
      if (maxPrice != null && test.price > maxPrice) {
        return false;
      }

      // Filter by discount percentage
      if (minDiscount != null || maxDiscount != null) {
        final discount = test.percentDiscount;

        if (minDiscount != null && discount < minDiscount) {
          return false;
        }
        if (maxDiscount != null && discount > maxDiscount) {
          return false;
        }
      }

      // Filter by author if specified
      if (author != null && author.isNotEmpty && test.author != author) {
        return false;
      }

      return true;
    }).toList();
  }
}
