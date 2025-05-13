import '../../domain/repositories/practice_test_repository.dart';
import '../models/practice_test/practice_test_card_model.dart';
import '../models/practice_test/practice_test_detail_model.dart';
import '../models/practice_test/practice_test_review_model.dart';
import '../services/practice_test/practice_test_service.dart';

class PracticeTestRepositoryImpl implements PracticeTestRepository {
  final PracticeTestService practiceTestService;

  PracticeTestRepositoryImpl({required this.practiceTestService});

  @override
  Future<List<PracticeTestCardModel>> getPracticeTests({
    String? search,
    int? courseId,
    int? accountId,
    int page = 0,
    int size = 10,
  }) async {
    return await practiceTestService.getPracticeTests(
      search: search,
      courseId: courseId,
      accountId: accountId,
      page: page,
      size: size,
    );
  }

  @override
  Future<PracticeTestDetailModel?> getPracticeTestDetail(
    int testId, {
    int? accountId,
  }) async {
    return await practiceTestService.getPracticeTestDetail(
      testId,
      accountId: accountId,
    );
  }

  @override
  Future<List<PracticeTestReviewModel>> getPracticeTestReviews(
    int testId, {
    int page = 0,
    int size = 10,
  }) async {
    return await practiceTestService.getPracticeTestReviews(
      testId,
      page: page,
      size: size,
    );
  }

  @override
  Future<bool> submitPracticeTestReview(
    int testId,
    int accountId,
    int rating, {
    String? review,
  }) async {
    return await practiceTestService.submitPracticeTestReview(
      testId,
      accountId,
      rating,
      review: review,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPracticeTestCategories() async {
    return await practiceTestService.getPracticeTestCategories();
  }
}
